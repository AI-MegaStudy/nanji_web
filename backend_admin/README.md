# Admin Backend Entry

## 목적
- `nanji_web`에서도 관리자 웹이 어떤 백엔드를 사용하는지 바로 보이게 하기 위한 얇은 진입 구조다.
- 실제 구현은 `nanji_app/Python/fastapi`의 공통 FastAPI를 사용한다.
- 여기에는 웹 관리자용 실행 진입점만 둔다.

## 구조
- `main.py`
  - 공통 FastAPI 앱을 import 하는 얇은 엔트리 파일
- `run_local_admin_backend.sh`
  - 로컬에서 관리자 웹용 FastAPI를 바로 실행하는 스크립트

## 실행 방법
```bash
cd /Users/electrozone/Documents/GitHub/nanji_web/backend_admin
./run_local_admin_backend.sh
```

## 주의사항
- 실제 비즈니스 로직과 DB 연결은 `nanji_app/Python/fastapi`에서 관리한다.
- 웹용 백엔드를 별도로 복붙해 두지 않는다.
- 앱과 관리자 웹은 같은 AWS RDS를 보도록 유지한다.
