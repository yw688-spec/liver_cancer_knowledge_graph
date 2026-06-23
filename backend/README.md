# HCC CDSS — 后端（FastAPI + Prolog）

把英文 Prolog 知识库通过 HTTP 以**中文标签 + 指南出处（src）**的 JSON 形式提供给前端。结构与出处来自 Prolog（权威来源），中文标签由 Python 本地化层附加。

## 架构

```
前端 index.html  ──HTTP/JSON──>  FastAPI (main.py)
                                     │
                                     ├── kb.py      pyswip 桥：常驻加载 KB，查询并附出处
                                     ├── labels.py  中文本地化层（也是日后 NL 的词库）
                                     │
                                     └──> Prolog:  hcc_kb.pl（事实+出处） + reasoning.pl（CNLC 分期推理）
```

设计要点：
- **Prolog 是事实与出处的唯一权威**。`kb.py` 查询得到结构和 `src(Guidelines, Section)`，`labels.py` 只负责把英文 atom 映射成中文显示名。
- **分期分类放在 Prolog**（`reasoning.pl` 的 `cnlc_classify/7`），并返回触发理由（`cnlc_classify_explained/8`），对应“可解释推理链”。核心 KB 不被修改。
- 每个端点的返回形状对齐前端现有的 `DB` 结构，前端从写死数据切到 `apiFetch` 基本是机械替换。

## 依赖

需要本机已安装 **SWI-Prolog**（`swipl` 在 PATH 中），然后：

```bash
cd backend
pip install -r requirements.txt        # fastapi, uvicorn, pyswip
```

> pyswip 通过本地 `libswipl` 与 SWI-Prolog 通信，所以必须先装好 swipl。

## 运行

```bash
cd backend
uvicorn main:app --reload --port 8000
```

KB 默认位于 `../hcc_kb`；如在别处，用环境变量指定：

```bash
HCC_KB_DIR=/path/to/hcc_kb uvicorn main:app --port 8000
```

启动后访问 `http://localhost:8000/health` 应返回 `{"status":"ok","facts":396,...}`。
交互式文档：`http://localhost:8000/docs`。

## 端点

| 方法 | 路径 | 说明 |
|------|------|------|
| GET  | `/health` | 状态、事实总数、四部指南 |
| POST | `/api/staging` | 患者参数 → CNLC 分期 + 治疗路线 + 出处 + 推理理由 |
| GET  | `/api/treatments/{stage}` | 指定分期（如 `Ia`）的治疗路线 |
| GET  | `/api/systemic-therapy?line=all\|first\|second` | 系统治疗方案 |
| GET  | `/api/evidence/filter?level=&grade=` | 按证据等级/推荐强度筛选 |
| GET  | `/api/diagnosis/risk-factors` | 高危因素 |
| GET  | `/api/diagnosis/imaging` | 影像方式 |
| GET  | `/api/diagnosis/ihc` | 免疫组化/分子标志物 |
| GET  | `/api/diagnosis/mvi` | MVI 分级 |
| GET  | `/api/diagnosis/molecular?group=` | 分子分型（`small_duct`/`large_duct`/`hcc`/`caca`/`all`） |
| GET  | `/api/framework` | 证据等级、推荐强度、指南列表 |
| GET  | `/api/facts-by-guideline/{code}` | 通用出处查询（`nhc`/`caca`/`nccn`/`esmo`） |
| POST | `/api/ask` | **中文自然语言问答**（LLM 工具调用 KB，答案带出处） |

### POST /api/staging 示例

请求：
```json
{ "ps": 1, "child_pugh": "A", "tumor_num": 1, "max_diameter": 4.0,
  "vascular_invasion": "present", "extrahepatic_metastasis": "absent" }
```
响应：
```json
{ "stage": "IIIa", "label": "CNLC IIIa 期", "bclc": "BCLC C（晚期·大血管侵犯）",
  "criteria": "...", "line1": "TACE/HAIC + 系统治疗", "line2": "手术（I/II 型癌栓）；放疗",
  "note": "主干癌栓不建议直接手术",
  "src": { "g": ["nhc"], "sec": "Treatment 4.1" },
  "reason": "macrovascular invasion (PVTT)" }
```

## 备注

- pyswip 引擎对并发查询不安全；`kb.py` 用一把锁串行化所有查询。研究/开发用途足够；如需高并发，可改用 swipl 子进程池或 SWI 内置 HTTP server。
- 高危因素等条目的 `note` 字段目前仍是 KB 中的英文权威描述（中文名在 `cn` 字段）；如需中文 note 可在 `labels.py` 补充。

## 自然语言问答层（`nl.py`，符号 + LLM）

`/api/ask` 用 LLM 的 **tool-use（function calling）** 把中文问题映射到知识库查询：

```
中文问题 ──> LLM 选择并调用工具 ──> kb.py 执行 Prolog 查询（事实 + 出处）
                                        │
       ┌────────────────────────────────┘
       └─> 工具结果回喂 LLM ──> LLM 仅据这些事实组织中文答案并标注出处
```

**关键约束（见 `nl.py` 的 SYSTEM 提示）**：LLM 不得使用知识库以外的医学知识、不得编造；每条结论必须标注指南出处；查不到就明说"知识库中暂无相关内容"；指南分歧时调用 `conflict_resolution` 并以 NHC 为准。这样事实层完全由符号 KB 把关，LLM 只负责语言理解与组织——即"符号 + 连接主义"的结合点。

暴露给 LLM 的工具：`cnlc_staging`、`stage_treatment`、`systemic_therapy`、`diagnosis`、`molecular`、`conflict_resolution`、`facts_by_guideline`、`search_kb`、`framework`。

**配置**：
```bash
export ANTHROPIC_API_KEY=sk-ant-...        # 必需
export HCC_LLM_MODEL=claude-sonnet-4-6     # 可选，默认 claude-sonnet-4-6
```

**返回**：`{ answer, tool_calls, citations }`——`answer` 为中文答案；`tool_calls` 是推理调用链（前端展示为"推理调用链"徽章）；`citations` 是去重后的 (事实, 出处) 列表，前端渲染为出处徽章。未配置 key 或调用失败时返回 `{answer: "问答服务暂不可用…", error}`，前端据此提示。

---

## 自然语言中文问答（DeepSeek + 结构化意图）

在结构化查询层之上新增的中文问答，核心安全设计是：**LLM 永不编写 Prolog、永不编造医学事实**，只做两件被严格限定的事。

### 管线

```
中文问题
  → llm.translate   (DeepSeek: 自然语言 → 结构化意图 JSON)
  → intents.validate (安全闸门: 白名单 + 槽位校验/归一化)
  → dispatch        (执行对应的 kb.py 查询 → Prolog 出事实+出处)
  → llm.narrate     (DeepSeek: 仅复述检索到的事实+出处)
  → {answer, intent, slots, facts, citations}
```

### 文件
- `intents.py` — 意图白名单 + 槽位校验（**安全闸门**）。LLM 只能选 intent 名 + 填槽位，Prolog 目标由后端用固定模板拼装；注入/非白名单/非法值在到达 KB 前一律拒绝。
- `llm.py` — DeepSeek 客户端，两个被限定的角色：`translate`（出意图 JSON）与 `narrate`（严格复述）。OpenAI 兼容接口，模型 `deepseek-v4-pro`。
- `nlq.py` — 编排：translate → validate → 查 KB → narrate。

### 配置与运行
```bash
export DEEPSEEK_API_KEY=你的key
# 可选: export DEEPSEEK_MODEL=deepseek-v4-pro
cd backend && uvicorn main:app --reload --port 8000
```
未设置 `DEEPSEEK_API_KEY` 时，`/api/ask` 返回提示而非报错；其余结构化端点不受影响。

### 端点
| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/ask` | body `{"question": "中文问题"}` → `{answer, intent, slots, facts, citations, configured}` |

### 安全性说明
- LLM 的输出被夹在两道闸门之间：① 只能映射到白名单意图（`intents.INTENTS`）；② 只能基于 KB 返回的事实叙述。
- 冲突主题等需要作为原子查询的槽位，用 `^[a-z0-9_]+$` 严格限制字符，杜绝把 `halt`、`shell(...)`、`retract(...)` 等注入推理引擎。
- `narrate` 的系统提示强制：只复述检索事实、每条结论标注指南出处、检索为空则明说、不补充库外知识。
