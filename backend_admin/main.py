from pathlib import Path
import sys

FASTAPI_ROOT = Path(__file__).resolve().parents[2] / 'nanji_app' / 'Python' / 'fastapi'
if str(FASTAPI_ROOT) not in sys.path:
    sys.path.insert(0, str(FASTAPI_ROOT))

from app.main import app
