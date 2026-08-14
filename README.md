# CarTracker – Vehicle Service & Maintenance Manager

A modern, full-stack web application for managing vehicles, maintenance records, documents, and reminders.

## Architecture

```
/
├── backend/       # Django 5 + DRF REST API
├── frontend/      # Flutter Web application
├── docker-compose.yml
└── .github/workflows/
```

## Features

- 🚗 **Vehicle Management** – Track all your vehicles with details, images, and mileage
- 🔧 **Maintenance Records** – Log services, repairs, and schedule upcoming maintenance
- 📄 **Documents** – Store insurance, registration, inspection documents with expiry tracking
- 🔔 **Reminders** – Get notified about upcoming maintenance and document renewals
- 🌐 **Demo Mode** – Works fully offline / on GitHub Pages without a backend
- 🌙 **Dark / Light Mode** – Material 3 design with theme switching
- 📱 **Responsive** – Optimized for Desktop & Tablet, works on mobile

## Demo

The frontend is deployed on GitHub Pages and automatically detects whether the backend is reachable.
When running in demo mode, all data is stored in browser local storage.

🔗 **Live Demo:** [https://kevbentoe.github.io/CarTracker/](https://kevbentoe.github.io/CarTracker/)

## Quick Start

### Backend (Development)

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

API available at: http://localhost:8000/api/v1/

Swagger UI: http://localhost:8000/api/v1/schema/swagger-ui/

### Frontend (Development)

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### Production (Docker)

```bash
cp backend/.env.example backend/.env
# Edit backend/.env with your production values
docker compose up -d
```

## API Documentation

Once the backend is running, visit:
- Swagger UI: http://localhost:8000/api/v1/schema/swagger-ui/
- ReDoc: http://localhost:8000/api/v1/schema/redoc/
- OpenAPI Schema: http://localhost:8000/api/v1/schema/

## Environment Variables

See `backend/.env.example` for all required environment variables.

## Tech Stack

| Layer     | Technology                               |
|-----------|------------------------------------------|
| Frontend  | Flutter Web, Dart, Material 3            |
| Backend   | Django 5, Django REST Framework          |
| Database  | PostgreSQL (prod) / SQLite (dev)         |
| Storage   | Pillow (images), Browser IndexedDB (demo)|
| CI/CD     | GitHub Actions, GitHub Pages             |
| Container | Docker, Docker Compose                   |

## Project Structure (Backend)

```
backend/
├── config/          # Django project settings & URLs
├── vehicles/        # Vehicle CRUD API
├── maintenance/     # Maintenance records API
├── documents/       # Document storage API
├── notifications/   # Reminders & notifications API
└── tests/           # Test suite
```

## License

MIT
