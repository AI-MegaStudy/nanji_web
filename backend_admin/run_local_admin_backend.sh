#!/bin/zsh
set -e

cd /Users/electrozone/Documents/GitHub/nanji_app/Python/fastapi
source .venv/bin/activate
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
