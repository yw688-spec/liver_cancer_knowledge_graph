#!/bin/bash
# start.sh — 本地快速启动脚本

set -e

echo "═══════════════════════════════════════"
echo "  肝癌诊疗决策支持系统 — 启动中"
echo "═══════════════════════════════════════"

# Check SWI-Prolog
if ! command -v swipl &> /dev/null; then
  echo ""
  echo "❌ 未检测到 SWI-Prolog (swipl)"
  echo "  macOS:   brew install swi-prolog"
  echo "  Ubuntu:  sudo apt-get install swi-prolog"
  exit 1
fi
echo "✓ SWI-Prolog: $(swipl --version 2>&1 | head -1)"

# Check Python
if ! command -v python3 &> /dev/null; then
  echo "❌ 未检测到 Python 3"
  exit 1
fi
echo "✓ Python: $(python3 --version)"

# Create virtual environment if not exists
if [ ! -d ".venv" ]; then
  echo ""
  echo "创建虚拟环境 .venv …"
  python3 -m venv .venv
fi

# Activate venv
source .venv/bin/activate
echo "✓ 虚拟环境已激活"

# Install dependencies
echo ""
echo "安装 Python 依赖…"
pip install -q -r backend/requirements.txt

# Start server
echo ""
echo "启动服务器…"
echo "访问地址: http://localhost:8000"
echo "API 文档: http://localhost:8000/docs"
echo ""
echo "按 Ctrl+C 停止服务"
echo "───────────────────────────────────────"

cd backend && uvicorn main:app --host 0.0.0.0 --port 8000 --reload
