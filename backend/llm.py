# -*- coding: utf-8 -*-
"""
llm.py -- DeepSeek client with two strictly-scoped roles.

ARCHITECTURE (per design decision): the LLM never writes Prolog and never
invents clinical facts. It does exactly two things:

  1) translate(question)      Chinese question  -> structured INTENT JSON
                              (an intent name + slots, chosen from a fixed
                               catalog; validated by intents.py before use).

  2) narrate(question, facts) retrieved KB facts -> a Chinese answer that ONLY
                              restates those facts + their provenance.

This keeps the model boxed in on both ends: it can only *route* to a whitelisted
query, and it can only *speak* from what the knowledge base returned.

Backend: DeepSeek, OpenAI-compatible endpoint (base_url=https://api.deepseek.com).
Model:   deepseek-v4-pro (translation quality matters more than cost).
Env:     DEEPSEEK_API_KEY  (optional: DEEPSEEK_MODEL, DEEPSEEK_BASE_URL)
"""
import json
import os
import re

import intents as I

_MODEL = os.environ.get("DEEPSEEK_MODEL", "deepseek-v4-pro")
_BASE_URL = os.environ.get("DEEPSEEK_BASE_URL", "https://api.deepseek.com")

_client = None


def client():
    """Lazily create an OpenAI-compatible client pointed at DeepSeek."""
    global _client
    if _client is None:
        from openai import OpenAI
        key = os.environ.get("DEEPSEEK_API_KEY")
        if not key:
            raise RuntimeError("DEEPSEEK_API_KEY 未设置")
        _client = OpenAI(api_key=key, base_url=_BASE_URL)
    return _client


def _intent_catalog():
    """Render the whitelisted intents + slots for the translator prompt."""
    lines = []
    for name, spec in I.INTENTS.items():
        slots = spec["slots"]
        if slots:
            sd = ", ".join(
                f"{s}{'(必填)' if r.get('required') else '(可选)'}" for s, r in slots.items())
        else:
            sd = "无槽位"
        lines.append(f"- {name}: {spec['desc']} | 槽位: {sd}")
    return "\n".join(lines)


_TRANSLATE_SYS = """你是一个医学知识库的查询翻译器。唯一任务：把用户的中文问题映射为一个结构化的 JSON 意图对象。

你只能从下面的意图目录中选择一个 intent 并填写其槽位。绝对不能编写 Prolog/SQL/任何代码，也不能直接回答医学问题。

意图目录：
{catalog}

槽位取值约束：
- stage 分期: Ia / Ib / IIa / IIb / IIIa / IIIb / IV
- line 治疗线: first(一线) / second(二线) / all(全部)
- level 证据等级: 1-5 整数; grade 推荐强度: a / b / c
- group 分子分型: small_duct / large_duct / hcc / caca / all
- guideline 指南: nhc(卫健委) / caca(抗癌协会) / nccn / esmo
- topic 冲突主题: 小写英文下划线标识符(如 hbv_antiviral、transplant_criteria)，不确定就留空

只输出一个 JSON 对象，不要任何解释或 markdown：
{{"intent": "意图名", "slots": {{"槽位名": "值"}}}}

无法对应任何意图时输出：{{"intent": "unknown", "slots": {{}}}}"""


_NARRATE_SYS = """你是一个严格的医学知识库问答助手。下面给你用户的问题，以及从知识库检索到的事实(JSON)。

铁律：
1. 只能复述检索结果中的事实，绝对不能补充知识库以外的医学信息、推测或常识。
2. 每条关键结论后用方括号标注出处指南与章节，例如 [卫健委 Treatment 4.1]。出处来自事实的 src 字段(g=指南代码列表，第一个是主要来源; sec=章节)。代码对应中文: nhc=卫健委, caca=抗癌协会, nccn=NCCN, esmo=ESMO。
3. 检索结果为空时直接说"知识库中未检索到相关信息"，不要编造。
4. 简体中文、简洁专业，可用条目组织，但不展开知识库没有的内容。
5. 结尾附一句："以上内容来自知识库检索，仅供参考，临床决策请结合多学科讨论(MDT)。"
"""


def translate(question, _client=None):
    """Chinese question -> raw intent dict (UNVALIDATED). Caller must validate."""
    cli = _client or client()
    sys = _TRANSLATE_SYS.format(catalog=_intent_catalog())
    resp = cli.chat.completions.create(
        model=_MODEL,
        messages=[
            {"role": "system", "content": sys},
            {"role": "user", "content": f"用户问题：{question}\n请输出 JSON 意图对象。"},
        ],
        response_format={"type": "json_object"},
        temperature=0,
        max_tokens=300,
    )
    return _parse_json(resp.choices[0].message.content)


def narrate(question, facts, _client=None):
    """Retrieved facts -> Chinese answer restating only those facts + provenance."""
    cli = _client or client()
    resp = cli.chat.completions.create(
        model=_MODEL,
        messages=[
            {"role": "system", "content": _NARRATE_SYS},
            {"role": "user", "content":
                f"用户问题：{question}\n\n检索到的事实(JSON)：\n"
                f"{json.dumps(facts, ensure_ascii=False, indent=1)}\n\n请据此回答。"},
        ],
        temperature=0,
        max_tokens=900,
    )
    return resp.choices[0].message.content


def _parse_json(text):
    """Robustly extract a JSON object from model output."""
    text = (text or "").strip()
    try:
        return json.loads(text)
    except Exception:
        pass
    m = re.search(r"\{.*\}", text, re.DOTALL)
    if m:
        try:
            return json.loads(m.group(0))
        except Exception:
            pass
    return {"intent": "unknown", "slots": {}}
