# -*- coding: utf-8 -*-
"""
intents.py -- Structured-intent schema + whitelist + safe Prolog builder.

This is the SECURITY GATE between the LLM and the Prolog engine. The LLM never
emits raw Prolog. It picks an `intent` name and fills `slots`; this module:
  1. checks the intent is whitelisted,
  2. validates/normalizes every slot against an allow-list or type,
  3. builds the Prolog goal itself from a fixed template.

Anything that doesn't match is rejected before it can reach the KB. There is no
code path that concatenates LLM free text into a Prolog goal.
"""
import re

# --- value allow-lists -------------------------------------------------------
STAGES = {"Ia", "Ib", "IIa", "IIb", "IIIa", "IIIb", "IV"}
# casual -> canonical
STAGE_ALIASES = {
    "ia": "Ia", "ib": "Ib", "iia": "IIa", "iib": "IIb",
    "iiia": "IIIa", "iiib": "IIIb", "iv": "IV",
    "Ⅰa": "Ia", "Ⅰb": "Ib", "Ⅱa": "IIa", "Ⅱb": "IIb",
    "Ⅲa": "IIIa", "Ⅲb": "IIIb", "Ⅳ": "IV",
}
GUIDELINES = {"nhc", "caca", "nccn", "esmo"}
GUIDELINE_ALIASES = {
    "卫健委": "nhc", "国家卫健委": "nhc", "nhc": "nhc",
    "抗癌协会": "caca", "中国抗癌协会": "caca", "caca": "caca",
    "nccn": "nccn", "美国": "nccn",
    "esmo": "esmo", "欧洲": "esmo",
}
EVID_LEVELS = {1, 2, 3, 4, 5}
GRADES = {"a", "b", "c"}
MOLECULAR_GROUPS = {"small_duct", "large_duct", "hcc", "caca", "all"}
SYSTEMIC_LINES = {"first", "second", "all"}
LINE_ALIASES = {"一线": "first", "首选": "first", "1线": "first", "first": "first",
                "二线": "second", "2线": "second", "second": "second",
                "全部": "all", "所有": "all", "all": "all"}


def _norm_line(v):
    s2 = str(v).strip()
    return LINE_ALIASES.get(s2, LINE_ALIASES.get(s2.lower(),
                            s2.lower() if s2.lower() in SYSTEMIC_LINES else None))

# --- safe atom guard ---------------------------------------------------------
# Conflict topics / molecular keys are atoms we look up; restrict hard to a
# conservative character class so nothing structural can be injected.
_SAFE_ATOM = re.compile(r"^[a-z0-9_]{1,40}$")


def _norm_stage(v):
    s = str(v).strip()
    if s in STAGES:
        return s
    return STAGE_ALIASES.get(s.lower(), STAGE_ALIASES.get(s))


def _norm_guideline(v):
    s = str(v).strip().lower()
    return GUIDELINE_ALIASES.get(s, s if s in GUIDELINES else None)


def _safe_atom(v):
    s = str(v).strip().lower()
    return s if _SAFE_ATOM.match(s) else None


# -----------------------------------------------------------------------------
# Intent registry.
#
# Each intent maps to a backend handler name (resolved in nlq.py) plus a slot
# spec. We deliberately route to the EXISTING kb.py functions / a small set of
# fixed Prolog templates rather than letting the model compose goals.
# -----------------------------------------------------------------------------
INTENTS = {
    # --- treatment / staging ---
    "treatment_for_stage": {
        "desc": "查询某个 CNLC 分期的治疗方案",
        "slots": {"stage": {"required": True, "norm": _norm_stage}},
    },
    "stage_definition": {
        "desc": "查询某个 CNLC 分期的定义与 BCLC 映射",
        "slots": {"stage": {"required": True, "norm": _norm_stage}},
    },
    # --- systemic therapy ---
    "systemic_therapy": {
        "desc": "查询系统治疗方案（可指定一线/二线）",
        "slots": {"line": {"required": False, "default": "all", "norm": _norm_line}},
    },
    "evidence_filter": {
        "desc": "按证据等级 / 推荐强度筛选系统治疗",
        "slots": {
            "level": {"required": False, "norm": lambda v: int(v) if str(v).isdigit() and int(v) in EVID_LEVELS else None},
            "grade": {"required": False, "norm": lambda v: str(v).lower() if str(v).lower() in GRADES else None},
        },
    },
    # --- diagnosis ---
    "risk_factors": {"desc": "查询肝癌高危因素", "slots": {}},
    "imaging": {"desc": "查询诊断影像方式", "slots": {}},
    "ihc_markers": {"desc": "查询免疫组化/分子标志物", "slots": {}},
    "mvi_grading": {"desc": "查询微血管侵犯 MVI 分级", "slots": {}},
    "molecular": {
        "desc": "查询分子分型（small_duct/large_duct/hcc/caca/all）",
        "slots": {"group": {"required": False, "default": "all",
                            "norm": lambda v: str(v).lower() if str(v).lower() in MOLECULAR_GROUPS else None}},
    },
    # --- provenance / conflict ---
    "facts_by_guideline": {
        "desc": "列出某部指南支持的事实",
        "slots": {"guideline": {"required": True, "norm": _norm_guideline}},
    },
    "conflict": {
        "desc": "查询跨指南冲突裁决（topic 可选，留空=全部）",
        "slots": {"topic": {"required": False, "norm": _safe_atom}},
    },
    "framework": {"desc": "证据等级与推荐强度体系", "slots": {}},
}


class IntentError(Exception):
    pass


def validate(intent_obj):
    """Validate a raw intent dict from the LLM. Returns (intent_name, clean_slots).
    Raises IntentError on anything not on the whitelist."""
    if not isinstance(intent_obj, dict):
        raise IntentError("intent 必须是对象")
    name = intent_obj.get("intent")
    if name not in INTENTS:
        raise IntentError(f"未知意图: {name!r}")
    spec = INTENTS[name]["slots"]
    raw_slots = intent_obj.get("slots") or {}
    if not isinstance(raw_slots, dict):
        raise IntentError("slots 必须是对象")

    clean = {}
    for slot, rule in spec.items():
        if slot in raw_slots and raw_slots[slot] not in (None, "", "null"):
            val = rule["norm"](raw_slots[slot])
            if val is None:
                raise IntentError(f"槽位 {slot} 的值非法: {raw_slots[slot]!r}")
            clean[slot] = val
        elif rule.get("required"):
            raise IntentError(f"缺少必填槽位: {slot}")
        elif "default" in rule:
            clean[slot] = rule["default"]
    return name, clean


# Conflict topic lookup uses a fixed Prolog template; the topic is a guarded
# atom (validated above). This is the only place we build a goal string with a
# slot value, and the value has already passed _SAFE_ATOM.
def conflict_goal(topic=None):
    if topic is None:
        return "conflict_resolution(Topic, Pos, Rule, src(Gs, Sec))"
    # topic guaranteed to match ^[a-z0-9_]+$
    return f"conflict_resolution({topic}, Pos, Rule, src(Gs, Sec))"
