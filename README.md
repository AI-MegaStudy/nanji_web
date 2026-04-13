# Nanji Parking Dashboard

A Flutter Web application for monitoring parking congestion in Han River parks.

## Features

- Overall parking status table
- Park selection dropdown
- Time-based prediction graphs
- Date/time filters
- Congestion color map/cards

## Getting Started

1. Ensure Flutter is installed.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run -d chrome` to start the web app.

## Admin Backend Entry

- Web 관리자 화면은 `nanji_app/Python/fastapi`의 공통 FastAPI를 사용합니다.
- `nanji_web/backend_admin` 폴더는 웹 팀원이 백엔드 진입점을 바로 찾을 수 있게 만든 얇은 구조입니다.
- 로컬 실행:

```bash
cd /Users/electrozone/Documents/GitHub/nanji_web/backend_admin
./run_local_admin_backend.sh
```

## Architecture

This app uses MVVM architecture with Provider for state management.

- Models: Data structures
- Views: UI components
- ViewModels: Business logic
