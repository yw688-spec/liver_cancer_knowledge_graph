# -*- coding: utf-8 -*-
"""
nlq.py -- Natural-language query orchestration (the symbolic+connectionist seam).

Pipeline for one Chinese question:

    question
      -> llm.translate          (LLM: NL -> raw intent JSON)
      -> intents.validate       (GATE: whitelist + slot validation/normalization)
      -> dispatch               (run the corresponding kb.py query against Prolog)
      -> llm.narrate            (LLM: facts -> Chinese answer, restate-only)
      -> {answer, intent, slots, facts, citations}

The LLM is boxed in on both ends: it can only pick a whitelisted intent, and it
can only speak from the facts the KB returned. All clinical content and every
citation originate in the Prolog knowledge base.
"""
import json

import kb
import intents as I
import llm


# --- intent name -> KB call (only whitelisted intents reach here) ----------
def _dispatch(name, slots):
    if name == "treatment_for_stage":
        return kb.treatments(slots["stage"])
    if name == "stage_definition":
        return kb.treatments(slots["stage"])  # payload carries criteria + bclc + roadmap
    if name == "systemic_therapy":
        return kb.systemic(slots.get("line", "all"))
    if name == "evidence_filter":
        return kb.evidence_filter(slots.get("level"), slots.get("grade"))
    if name == "risk_factors":
        return kb.risk_factors()
    if name == "imaging":
        return kb.imaging()
    if name == "ihc_markers":
        return kb.ihc()
    if name == "mvi_grading":
        return kb.mvi()
    if name == "molecular":
        return kb.molecular(slots.get("group", "all"))
    if name == "facts_by_guideline":
        return kb.facts_by_guideline(slots["guideline"])
    if name == "conflict":
        return kb.conflict_resolution(slots.get("topic"))
    if name == "framework":
        return kb.framework()
    return {"error": f"unhandled intent {name}"}


def _collect_citations(obj, acc=None, seen=None):
    """Recursively gather distinct (label, src) provenance pairs for the UI."""
    if acc is None:
        acc, seen = [], set()
    if isinstance(obj, dict):
        if isinstance(obj.get("src"), dict):
            src = obj["src"]
            label = (obj.get("cn") or obj.get("label") or obj.get("topic")
                     or obj.get("marker") or obj.get("fact") or "")
            key = (label, tuple(src.get("g", [])), src.get("sec"))
            if key not in seen:
                seen.add(key)
                acc.append({"label": label, "src": src})
        for v in obj.values():
            _collect_citations(v, acc, seen)
    elif isinstance(obj, list):
        for v in obj:
            _collect_citations(v, acc, seen)
    return acc


def ask(question, translate_client=None, narrate_client=None):
    """Run the full grounded NL pipeline for one question."""
    # 1) LLM translates to an intent (may raise on network/key errors upstream)
    raw = llm.translate(question, _client=translate_client)

    # 2) Security gate: validate against the whitelist
    try:
        name, slots = I.validate(raw)
    except I.IntentError as e:
        return {
            "answer": f"未能将问题映射到知识库的可用查询（{e}）。可以换种问法，"
                      f"例如询问某个分期的治疗、系统治疗方案、高危因素、或跨指南冲突。",
            "intent": raw.get("intent"), "slots": {}, "facts": [], "citations": [],
        }

    # 3) Query the Prolog KB
    facts = _dispatch(name, slots)

    # 4) LLM narrates strictly from the retrieved facts
    answer = llm.narrate(question, facts, _client=narrate_client)

    return {
        "answer": answer,
        "intent": name,
        "slots": slots,
        "facts": facts,
        "citations": _collect_citations(facts),
    }
