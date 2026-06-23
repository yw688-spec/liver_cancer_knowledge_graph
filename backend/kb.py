# -*- coding: utf-8 -*-
"""
kb.py -- Prolog knowledge-base bridge.

Loads the English HCC Prolog KB once (persistent in-process via pyswip) and
exposes query functions that return frontend-shaped dicts. The STRUCTURE and
PROVENANCE (src) come from Prolog; Chinese display labels are merged in from
labels.py. This keeps the KB authoritative and English while the API speaks
Chinese.
"""
import os
import re
import threading

from pyswip import Prolog

import labels as L

# Path to the Prolog KB directory (override with HCC_KB_DIR env var).
# Default: the sibling `prolog/` folder in the project layout
#   liver_cancer_system/{backend,prolog,frontend}
_PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_DEFAULT_KB_DIR = os.path.join(_PROJECT_ROOT, "prolog")
KB_DIR = os.environ.get("HCC_KB_DIR", _DEFAULT_KB_DIR)

_prolog = None
_lock = threading.Lock()  # pyswip engine is not safe for concurrent queries


def _engine():
    global _prolog
    if _prolog is None:
        if not os.path.isfile(os.path.join(KB_DIR, "hcc_kb.pl")):
            raise FileNotFoundError(f"hcc_kb.pl not found in {KB_DIR}; set HCC_KB_DIR.")
        p = Prolog()
        # Absolute paths: SWI resolves the ensure_loaded(...) of sibling modules
        # inside hcc_kb.pl relative to that file's own directory, so this works
        # regardless of the process working directory.
        main_pl = os.path.join(KB_DIR, "hcc_kb.pl").replace("\\", "/")
        reasoning_pl = os.path.join(KB_DIR, "reasoning.pl").replace("\\", "/")
        references_pl = os.path.join(KB_DIR, "references.pl").replace("\\", "/")
        list(p.query(f"consult('{main_pl}')"))
        list(p.query(f"consult('{reasoning_pl}')"))
        list(p.query(f"consult('{references_pl}')"))
        _prolog = p
    return _prolog


def q(goal):
    """Run a Prolog goal, return list of binding dicts. Thread-safe."""
    with _lock:
        return list(_engine().query(goal))


# ---- helpers --------------------------------------------------------------
_ref_cache = None


def _references():
    """Load {(guideline, section): {doc, title, loc}} once from references.pl."""
    global _ref_cache
    if _ref_cache is None:
        docs = {str(r["G"]): str(r["Doc"]) for r in q("guideline_doc(G, Doc)")}
        cache = {}
        for r in q("reference(Section, Guideline, Title, Loc)"):
            g = str(r["Guideline"])
            cache[(g, str(r["Section"]))] = {
                "doc": docs.get(g, g),
                "title": str(r["Title"]),
                "loc": str(r["Loc"]),
            }
        _ref_cache = cache
    return _ref_cache


def _src(gs, sec):
    """Build the frontend provenance object from a Prolog src(Gs, Sec),
    attaching real bibliographic references where references.pl has them."""
    gs = list(gs)
    sec = str(sec)
    refs = []
    table = _references()
    for g in gs:
        hit = table.get((str(g), sec))
        if hit:
            refs.append({"g": str(g), **hit})
    return {"g": gs, "sec": sec, "refs": refs}


def _clean_fact(goal_str):
    """Drop the trailing src(...) term from a printed goal; provenance is
    returned separately, and pyswip renders deep atoms unreadably."""
    i = goal_str.rfind(", src(")
    return (goal_str[:i] + ")") if i != -1 else goal_str


_LVL = re.compile(r"L(\d)")
_REC = re.compile(r"Rec\s+([ABC])")


def parse_grade(s):
    """Parse a KB grade string ('L1/Rec A', 'NCCN Cat.1', 'not recommended', ...)
    into (level:int|None, grade:'a'|'b'|'c'|None, recommended:bool)."""
    s = (s or "").strip()
    if "not recommended" in s.lower():
        return (None, None, False)
    level = int(_LVL.search(s).group(1)) if _LVL.search(s) else None
    m = _REC.search(s)
    grade = m.group(1).lower() if m else None
    if "Cat.1" in s:
        level = level or 1
        grade = grade or "a"
    return (level, grade, True)


# ---- health / meta --------------------------------------------------------
def health():
    total = q("aggregate_all(count, "
              "(kb_fact_predicate(_, Name/Arity), functor(G, Name, Arity), call(G)), N)")
    guidelines = []
    for r in q("guideline(Code, Short, Full, Year, Role)"):
        code = str(r["Code"])
        guidelines.append({
            "code": code, "short": str(r["Short"]), "year": r["Year"],
            "cn": L.GUIDELINE_CN.get(code, str(r["Full"])),
        })
    return {"status": "ok", "facts": total[0]["N"] if total else 0, "guidelines": guidelines}


# ---- staging / treatment --------------------------------------------------
_CP_ATOM = {"A": "'A'", "B": "'B'", "C": "'C'"}


def _stage_payload(stage):
    """Assemble the Chinese stage card for a CNLC stage atom (e.g. 'Ia')."""
    crit = q(f"cnlc_stage('{stage}', Desc, src(Gs, Sec))")
    tr = q(f"stage_treatment('{stage}', L1, L2, Note, src(Gs, Sec))")
    out = {
        "stage": stage,
        "label": L.STAGE_CN.get(stage, f"CNLC {stage}"),
        "bclc": L.BCLC_CN.get(stage, ""),
        "criteria": L.STAGE_CRITERIA_CN.get(stage, crit[0]["Desc"]) if crit else "",
        "src": _src(crit[0]["Gs"], crit[0]["Sec"]) if crit else None,
    }
    if tr:
        t = tr[0]
        out["line1"] = L.STAGE_LINE_CN.get(str(t["L1"]), str(t["L1"]))
        out["line2"] = L.STAGE_LINE_CN.get(str(t["L2"]), str(t["L2"]))
        out["note"] = L.STAGE_NOTE_CN.get(stage, str(t["Note"]))
        out["src"] = _src(t["Gs"], t["Sec"])  # treatment src is the roadmap source
    return out


def staging(ps, child_pugh, tumor_num, max_diameter, vascular_invasion, extrahepatic_metastasis):
    cp = _CP_ATOM.get(str(child_pugh).upper(), "'A'")
    v = "present" if vascular_invasion in ("present", True, "true", 1) else "absent"
    e = "present" if extrahepatic_metastasis in ("present", True, "true", 1) else "absent"
    r = q(f"cnlc_classify_explained({int(ps)}, {cp}, {int(tumor_num)}, "
          f"{float(max_diameter)}, {v}, {e}, Stage, Reason)")
    if not r:
        return {"error": "classification failed"}
    stage = str(r[0]["Stage"])
    payload = _stage_payload(stage)
    raw_reason = str(r[0]["Reason"])
    payload["reason"] = L.REASON_CN.get(raw_reason, raw_reason)  # Chinese, fallback English
    return payload


def treatments(stage):
    return _stage_payload(_norm_stage(stage))


_STAGE_CANON = {"IA": "Ia", "IB": "Ib", "IIA": "IIa", "IIB": "IIb",
                "IIIA": "IIIa", "IIIB": "IIIb", "IV": "IV"}


def _norm_stage(stage):
    """Accept 'ia'/'Ia'/'IA' etc. -> canonical 'Ia'."""
    return _STAGE_CANON.get(str(stage).upper(), str(stage))


# ---- liver function: Child-Pugh + ALBI from labs --------------------------
_ASCITES = {"none", "mild", "moderate"}
_ENCEPH = {"none", "grade1_2", "grade3_4"}
_ASCITES_CN = {"none": "无", "mild": "轻度（药物可控）", "moderate": "中-重度"}
_ENCEPH_CN = {"none": "无", "grade1_2": "1-2 级", "grade3_4": "3-4 级"}
_CP_ITEM_CN = {"bilirubin": "总胆红素", "albumin": "白蛋白", "inr": "INR",
               "ascites": "腹水", "encephalopathy": "肝性脑病"}


def _bilirubin_umol(value, unit):
    """Canonicalise bilirubin to umol/L (1 mg/dL = 17.1 umol/L)."""
    return float(value) * 17.1 if unit == "mg/dL" else float(value)


def _albumin_gl(value, unit):
    """Canonicalise albumin to g/L (1 g/dL = 10 g/L)."""
    return float(value) * 10.0 if unit == "g/dL" else float(value)


def liver_function(bilirubin, bilirubin_unit, albumin, albumin_unit,
                   inr, ascites, encephalopathy):
    """Compute Child-Pugh class + ALBI grade from labs, with the per-item
    derivation and guideline provenance. Units are normalised to umol/L (bili)
    and g/L (albumin); the raw inputs are echoed back for the audit trail."""
    if ascites not in _ASCITES:
        return {"error": f"invalid ascites: {ascites!r}"}
    if encephalopathy not in _ENCEPH:
        return {"error": f"invalid encephalopathy: {encephalopathy!r}"}

    bili = _bilirubin_umol(bilirubin, bilirubin_unit)
    alb = _albumin_gl(albumin, albumin_unit)

    cp = q(f"child_pugh_from_labs({bili}, {alb}, {float(inr)}, {ascites}, "
           f"{encephalopathy}, Class, Score, PB, PA, PI, PAsc, PEn)")
    if not cp:
        return {"error": "child-pugh computation failed"}
    c = cp[0]
    cp_class = str(c["Class"])
    cp_src = q(f"child_pugh('{cp_class}', _, _, src(Gs, Sec))")
    points = {"bilirubin": c["PB"], "albumin": c["PA"], "inr": c["PI"],
              "ascites": c["PAsc"], "encephalopathy": c["PEn"]}

    albi = q(f"albi_from_labs({bili}, {alb}, Grade, Score)")
    albi_out = None
    if albi:
        grade = albi[0]["Grade"]
        albi_src = q(f"albi_grade({grade}, _, src(Gs, Sec))")
        albi_out = {
            "grade": grade,
            "score": round(float(albi[0]["Score"]), 3),
            "src": _src(albi_src[0]["Gs"], albi_src[0]["Sec"]) if albi_src else None,
        }

    return {
        "child_pugh": {
            "class": cp_class,
            "score": c["Score"],
            "points": [{"item": _CP_ITEM_CN[k], "point": v} for k, v in points.items()],
            "src": _src(cp_src[0]["Gs"], cp_src[0]["Sec"]) if cp_src else None,
        },
        "albi": albi_out,
        "normalized": {"bilirubin_umol_l": round(bili, 2), "albumin_g_l": round(alb, 2),
                       "inr": float(inr),
                       "ascites": _ASCITES_CN[ascites],
                       "encephalopathy": _ENCEPH_CN[encephalopathy]},
    }


def conflict(topic=None):
    """Cross-guideline conflict-resolution entries (NHC-anchored ruling).
    If `topic` is given, keep entries whose topic atom contains it (substring)."""
    out = []
    for r in q("conflict_resolution(Topic, Pos, Rule, src(Gs, Sec))"):
        t = str(r["Topic"])
        if topic and topic.lower() not in t.lower():
            continue
        out.append({
            "topic": t,
            "position": str(r["Pos"]),
            "rule": str(r["Rule"]),
            "src": _src(r["Gs"], r["Sec"]),
        })
    return out


# ---- systemic therapy -----------------------------------------------------
def _systemic_rows(predicate, line):
    rows = []
    # 1L: (Id, Trial, Data, Grade, src); 2L: (Id, Cond, Data, Grade, src)
    for r in q(f"{predicate}(Id, A2, Data, Grade, src(Gs, Sec))"):
        atom = str(r["Id"])
        level, grade, rec = parse_grade(str(r["Grade"]))
        rows.append({
            "id": atom,
            "cn": L.SYSTEMIC_CN.get(atom, atom),
            "trial": str(r["A2"]) if line == "first" else "",
            "condition": "" if line == "first" else str(r["A2"]),
            "data": str(r["Data"]),
            "note": L.SYSTEMIC_NOTE_CN.get(atom, str(r["Data"])),
            "line": line,
            "level": level, "grade": grade, "recommended": rec,
            "src": _src(r["Gs"], r["Sec"]),
        })
    return rows


def systemic(line="all"):
    rows = []
    if line in ("all", "first"):
        rows += _systemic_rows("systemic_1l", "first")
    if line in ("all", "second"):
        rows += _systemic_rows("systemic_2l", "second")
    return rows


def evidence_filter(level=None, grade=None):
    rows = systemic("all")
    out = []
    for r in rows:
        if level is not None and str(r["level"]) != str(level):
            continue
        if grade is not None and r["grade"] != grade:
            continue
        out.append(r)
    return out


# ---- diagnosis ------------------------------------------------------------
def risk_factors():
    out = []
    for r in q("risk_factor(Id, Cat, Desc, src(Gs, Sec))"):
        atom = str(r["Id"])
        out.append({
            "id": atom,
            "cn": L.RISK_CN.get(atom, atom),
            "cat": L.RISK_CATEGORY_CN.get(str(r["Cat"]), str(r["Cat"])),
            "note": L.RISK_NOTE_CN.get(atom, str(r["Desc"])),
            "src": _src(r["Gs"], r["Sec"]),
        })
    return out


def imaging():
    out = []
    for r in q("imaging_modality(Id, Use, Grade, src(Gs, Sec))"):
        atom = str(r["Id"])
        out.append({
            "id": atom,
            "cn": L.IMAGING_CN.get(atom, atom),
            "use": L.IMAGING_USE_CN.get(atom, str(r["Use"])),
            "grade": str(r["Grade"]),
            "src": _src(r["Gs"], r["Sec"]),
        })
    return out


def ihc():
    out = []
    for r in q("ihc_marker(Cat, Markers, src(Gs, Sec))"):
        cat = str(r["Cat"])
        out.append({
            "cn": L.IHC_CN.get(cat, cat),
            "markers": str(r["Markers"]),
            "src": _src(r["Gs"], r["Sec"]),
        })
    return out


def mvi():
    out = []
    for r in q("mvi_grade(G, Def, Risk, src(Gs, Sec))"):
        key = str(r["G"])
        label, cn_def, cn_risk = L.MVI_CN.get(key, (key, str(r["Def"]), str(r["Risk"])))
        out.append({
            "grade": label, "cn": cn_def,
            "risk": L.MVI_RISK_CN.get(str(r["Risk"]), cn_risk),
            "src": _src(r["Gs"], r["Sec"]),
        })
    return out


def molecular(group="all"):
    out = []
    for (pred, key, grp, grp_cn, marker_cn) in L.MOLECULAR:
        if group != "all" and grp != group:
            continue
        rows = q(f"{pred}({key}, _, src(Gs, Sec))")
        if not rows:
            continue
        out.append({
            "group": grp, "groupCn": grp_cn,
            "marker": marker_cn,
            "src": _src(rows[0]["Gs"], rows[0]["Sec"]),
        })
    return out


# ---- evidence framework ---------------------------------------------------
def framework():
    ocebm = []
    for r in q("evidence_level(nhc, Lvl, Desc, src(Gs, Sec))"):
        lvl = r["Lvl"]
        ocebm.append({"level": lvl, "cn": L.OCEBM_CN.get(lvl, str(r["Desc"])),
                      "src": _src(r["Gs"], r["Sec"])})
    ocebm.sort(key=lambda x: x["level"])
    grades = []
    for r in q("recommendation_strength(G, Desc, _, _, src(Gs, Sec))"):
        g = str(r["G"])
        grades.append({"grade": g.lower(), "cn": L.GRADE_CN.get(g, str(r["Desc"])),
                       "src": _src(r["Gs"], r["Sec"])})
    grades.sort(key=lambda x: x["grade"])
    return {"ocebm": ocebm, "grades": grades, "guidelines": health()["guidelines"]}


# ---- generic provenance (useful for the future NL layer) ------------------
def facts_by_guideline(code):
    rows = q(f"fact_with_source(Goal, src(Gs, Sec)), memberchk({code}, Gs)")
    out = []
    for r in rows:
        out.append({"fact": _clean_fact(str(r["Goal"])), "src": _src(r["Gs"], r["Sec"])})
    return out


def conflict_resolution(topic=None):
    """Cross-guideline conflict-resolution entries (NHC-anchored rulings).
    Pass a topic atom to filter, or None for all."""
    sel = topic if topic else "Topic"
    rows = q(f"conflict_resolution({sel}, Position, Rule, src(Gs, Sec))")
    out = []
    for r in rows:
        out.append({
            "topic": topic if topic else str(r["Topic"]),
            "position": str(r["Position"]),
            "rule": str(r["Rule"]),
            "src": _src(r["Gs"], r["Sec"]),
        })
    return out


def search_kb(keyword, limit=25):
    """Free-text search across every sourced fact; returns matching facts + src.
    Case-insensitive substring match on the printed fact term."""
    kw = (keyword or "").lower()
    out = []
    for r in q("fact_with_source(Goal, src(Gs, Sec))"):
        goal = str(r["Goal"])
        if kw in goal.lower():
            out.append({"fact": _clean_fact(goal), "src": _src(r["Gs"], r["Sec"])})
            if len(out) >= limit:
                break
    return out
