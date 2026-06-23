# 肝癌诊疗决策支持系统 (liver_cancer_system)

符号知识库（Prolog）+ 连接主义（LLM）的肝癌临床决策支持系统。知识库整合四部指南
（国家卫健委 NHC 2026、中国抗癌协会 CACA 2026、NCCN 2026、ESMO 2025），**每条事实标注指南出处**，
以 NHC 为最终权威。前端中文展示，后端用 FastAPI 把 Prolog 事实以中文 + 出处的 JSON 提供，
并提供基于 DeepSeek 的中文自然语言问答（LLM 只翻译与复述，临床事实全部来自知识库）。

## 目录结构

```
liver_cancer_system/
├── prolog/              # 符号知识库（事实 + 出处 + 推理 + 测试）
│   ├── hcc_kb.pl        #   集成入口：加载全部模块 + 查询接口
│   ├── sources.pl       #   指南登记 + 权威排序 + 出处辅助
│   ├── ontology.pl      #   模块1 本体
│   ├── grading.pl       #   分级/分期（CNLC、Child-Pugh、MVI…）
│   ├── diagnosis.pl     #   模块3 诊断
│   ├── treatment.pl     #   模块4 治疗
│   ├── evidence.pl      #   模块2 证据体系 + 冲突裁决
│   ├── reasoning.pl     #   推理层：CNLC 分期分类器（可解释）
│   └── tests.pl         #   plunit 回归测试（20 条）
├── backend/             # FastAPI + pyswip 桥 + 中文 NL 层
│   ├── main.py          #   FastAPI 应用与端点
│   ├── kb.py            #   Prolog 桥：常驻加载 KB，查询并附出处
│   ├── labels.py        #   中文本地化层（也是 NL 词库）
│   ├── intents.py       #   NL 安全闸门：意图白名单 + 槽位校验
│   ├── llm.py           #   DeepSeek：translate（NL→意图）/ narrate（复述）
│   ├── nlq.py           #   NL 编排：translate→validate→查KB→narrate
│   └── requirements.txt
├── frontend/
│   └── index.html       # 单文件前端（在线走后端，离线回退内置数据）
├── docker/
│   └── Dockerfile       # 后端镜像（含 swi-prolog）
├── docker-compose.yml   # 一键起 后端 + 前端
├── start.sh             # 本地一键启动（非 Docker）
└── README.md
```

## 依赖

- **SWI-Prolog**（`swipl` 在 PATH 中）— pyswip 通过它加载知识库
  - macOS: `brew install swi-prolog`
- **Python 3.10+**
- AI 问答需要 **DeepSeek API key**（可选；不配则该功能停用，其余正常）

## 运行

### 方式一：本地一键启动（推荐先用这个，已验证）

```bash
cd liver_cancer_system
export DEEPSEEK_API_KEY=你的key      # 可选，启用 AI 问答
./start.sh
```
打开 **http://localhost:5500**。后端在 8000，接口文档 http://localhost:8000/docs。

> 首次运行若提示 `start.sh` 无执行权限：`chmod +x start.sh`。

### 方式二：Docker

```bash
cd liver_cancer_system
DEEPSEEK_API_KEY=你的key docker compose up --build
```
前端 http://localhost:5500，后端 http://localhost:8000。

## 怎么运行测试

### 1) Prolog 知识库回归测试（20 条断言，无需 Python）

```bash
cd prolog
swipl -q -g "(run_tests -> halt(0) ; halt(1))" tests.pl
```
全过则进程退出码为 0（打印一排 `.`）；任何回归会打印失败的测试名、文件:行号与“期望 vs 实际”，退出码非 0（适合接 CI）。

### 2) 后端接口冒烟测试（验证 Prolog 桥 + 出处）

先起后端（`./start.sh` 或单独 `cd backend && HCC_KB_DIR=../prolog uvicorn main:app --port 8000`），然后：

```bash
# 健康检查：应返回 {"status":"ok","facts":396,...}
curl -s http://localhost:8000/health

# 分期 + 治疗 + 推理依据 + 出处
curl -s -X POST http://localhost:8000/api/staging \
  -H 'Content-Type: application/json' \
  -d '{"ps":1,"child_pugh":"A","tumor_num":1,"max_diameter":4.0,"vascular_invasion":"present","extrahepatic_metastasis":"absent"}'

# 二线系统治疗
curl -s "http://localhost:8000/api/systemic-therapy?line=second"

# 跨指南冲突（通用出处遍历）
curl -s http://localhost:8000/api/facts-by-guideline/esmo
```

### 3) AI 中文问答测试（需 DEEPSEEK_API_KEY）

```bash
curl -s -X POST http://localhost:8000/api/ask \
  -H 'Content-Type: application/json' \
  -d '{"question":"索拉非尼进展后二线该用什么？"}'
```
返回 `{answer, intent, slots, facts, citations, configured}`。未配 key 时 `configured:false` 并给出提示。
也可直接在前端「中文问答（AI）」面板提问。

### 4) 前端

用浏览器打开前端（经 http://localhost:5500，不要直接双击 `file://`，否则个别浏览器会拦跨域请求）。
顶部状态点变绿 = 实时查询后端；后端没开则显示“离线演示”，自动用内置数据，功能不受影响。

## 安全说明（AI 问答）

LLM 被夹在两道闸门之间：① 只能把问题映射到 `intents.py` 中的**白名单意图 + 槽位**，Prolog 目标由后端用固定模板安全拼装（杜绝 `halt`/`shell`/`retract` 等注入）；② 回答阶段只能复述知识库检索到的事实并标注出处，禁止补充库外内容。
