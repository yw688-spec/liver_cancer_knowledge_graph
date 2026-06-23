# -*- coding: utf-8 -*-
"""
main.py -- FastAPI backend for the HCC clinical decision-support system.

Serves the English Prolog knowledge base as Chinese-labelled JSON, with the
guideline provenance (src) attached to every entry. Endpoints mirror the shapes
the frontend already renders, so wiring the UI is a matter of swapping its
hardcoded `DB` for `apiFetch` calls.

Run:
    cd backend
    pip install -r requirements.txt
    uvicorn main:app --reload --port 8000
"""
from fastapi import FastAPI, Header, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel

import audit
import kb

from dotenv import load_dotenv
load_dotenv()

app = FastAPI(title="HCC CDSS API", version="0.1.0")

# Allow the static frontend (opened from file:// or a dev server) to call us.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    info = kb.health()
    info["kb_version"] = audit.kb_version()
    return info


@app.get("/api/kb-version")
def api_kb_version():
    return {"kb_version": audit.kb_version()}


# ----- staging & treatment -----
class StagingInput(BaseModel):
    ps: int = 0
    child_pugh: str = "A"
    tumor_num: int = 1
    max_diameter: float = 3.0
    vascular_invasion: str = "absent"      # present | absent
    extrahepatic_metastasis: str = "absent"  # present | absent
    patient_ref: str | None = None           # pseudonym only, never a name


@app.post("/api/staging")
def api_staging(inp: StagingInput,
                x_user_id: str | None = Header(None),
                x_user_role: str | None = Header(None)):
    result = kb.staging(inp.ps, inp.child_pugh, inp.tumor_num, inp.max_diameter,
                        inp.vascular_invasion, inp.extrahepatic_metastasis)
    # Fail-closed: record the decision before returning it. A recommendation the
    # physician can see but the audit trail did not capture would defeat the
    # purpose, so an audit failure surfaces as a 500 rather than a silent result.
    rec = audit.record_decision(
        endpoint="/api/staging",
        inp=inp.model_dump(),
        output=result,
        user_id=x_user_id, role=x_user_role, patient_ref=inp.patient_ref,
        rule_chain=result.get("reason"),
        citations=[result["src"]] if result.get("src") else [],
    )
    result["decision_id"] = rec["decision_id"]
    return result


@app.get("/api/treatments/{stage}")
def api_treatments(stage: str):
    return kb.treatments(stage)


# ----- liver function: Child-Pugh + ALBI from labs -----
# A calculator, not a recommendation, so it is not audited on its own; when its
# result feeds /api/staging, that decision records the raw inputs.
class LiverFunctionInput(BaseModel):
    bilirubin: float
    bilirubin_unit: str = "umol/L"       # umol/L | mg/dL
    albumin: float
    albumin_unit: str = "g/L"            # g/L | g/dL
    inr: float
    ascites: str = "none"                # none | mild | moderate
    encephalopathy: str = "none"         # none | grade1_2 | grade3_4


@app.post("/api/liver-function")
def api_liver_function(inp: LiverFunctionInput):
    return kb.liver_function(inp.bilirubin, inp.bilirubin_unit,
                             inp.albumin, inp.albumin_unit, inp.inr,
                             inp.ascites, inp.encephalopathy)


# ----- systemic therapy & evidence -----
@app.get("/api/systemic-therapy")
def api_systemic(line: str = Query("all", pattern="^(all|first|second)$")):
    return {"regimens": kb.systemic(line)}


@app.get("/api/evidence/filter")
def api_evidence_filter(level: int | None = None, grade: str | None = None):
    return {"results": kb.evidence_filter(level, grade.lower() if grade else None)}


# ----- diagnosis -----
@app.get("/api/diagnosis/risk-factors")
def api_risk():
    return {"risk_factors": kb.risk_factors()}


@app.get("/api/diagnosis/imaging")
def api_imaging():
    return {"imaging": kb.imaging()}


@app.get("/api/diagnosis/ihc")
def api_ihc():
    return {"markers": kb.ihc()}


@app.get("/api/diagnosis/mvi")
def api_mvi():
    return {"mvi_grades": kb.mvi()}


@app.get("/api/diagnosis/molecular")
def api_molecular(group: str = "all"):
    return {"markers": kb.molecular(group)}


# ----- framework -----
@app.get("/api/framework")
def api_framework():
    return kb.framework()


# ----- generic provenance (basis for the future NL layer) -----
@app.get("/api/facts-by-guideline/{code}")
def api_facts_by_guideline(code: str):
    return {"code": code, "facts": kb.facts_by_guideline(code)}


# ----- natural-language (Chinese) Q&A: LLM translates to a whitelisted intent,
#       the KB answers, the LLM narrates strictly from the retrieved facts -----
class AskInput(BaseModel):
    question: str


@app.post("/api/ask")
def api_ask(inp: AskInput,
            x_user_id: str | None = Header(None),
            x_user_role: str | None = Header(None)):
    import os
    if not os.environ.get("DEEPSEEK_API_KEY"):
        return {"answer": "（未配置 LLM：请设置环境变量 DEEPSEEK_API_KEY 后重启后端）",
                "intent": None, "slots": {}, "facts": [], "citations": [], "configured": False}
    import nlq
    error = None
    try:
        result = nlq.ask(inp.question)
        result["configured"] = True
    except Exception as e:
        error = str(e)
        result = {"answer": f"（问答出错：{e}）", "intent": None, "slots": {},
                  "facts": [], "citations": [], "configured": True, "error": error}
    # Both successful answers and failures are recorded, so an erroneous Q&A
    # session is still reproducible and attributable in the audit trail.
    rec = audit.record_decision(
        endpoint="/api/ask",
        inp={"question": inp.question},
        output={"answer": result.get("answer"), "intent": result.get("intent"),
                "slots": result.get("slots"), "error": error},
        user_id=x_user_id, role=x_user_role,
        rule_chain=result.get("intent") or ("error" if error else ""),
        citations=result.get("citations"),
    )
    result["decision_id"] = rec["decision_id"]
    return result


# ----- audit trail -----
class DispositionInput(BaseModel):
    action: str            # accept | override | modify
    reason: str | None = None


@app.post("/api/audit/{record_id}/disposition")
def api_disposition(record_id: str, inp: DispositionInput,
                    x_user_id: str | None = Header(None),
                    x_user_role: str | None = Header(None)):
    try:
        rec = audit.set_disposition(record_id, inp.action, inp.reason,
                                    user_id=x_user_id, role=x_user_role)
    except audit.DispositionError as e:
        return JSONResponse(status_code=400, content={"error": str(e)})
    if rec is None:
        return JSONResponse(status_code=404,
                            content={"error": f"decision not found: {record_id}"})
    return rec


@app.get("/api/audit/verify")
def api_audit_verify():
    return audit.verify_chain()


@app.get("/api/audit/{record_id}")
def api_audit_get(record_id: str):
    rec = audit.get_record(record_id)
    if rec is None:
        return JSONResponse(status_code=404,
                            content={"error": f"record not found: {record_id}"})
    return rec
