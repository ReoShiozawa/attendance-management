# Attendance Management System (kinntai)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)](https://docs.docker.com/compose/)
[![Python](https://img.shields.io/badge/Python-3.11-green.svg)](https://www.python.org/)
[![ARM64](https://img.shields.io/badge/Assembly-ARM64-red.svg)](./attendance.s)

A full-stack attendance management system combining ARM64 Assembly, FastAPI, and Vanilla JS. Includes JWT authentication and user management — launch everything with a single `docker-compose up` command.

> **This is a learning project.** The goal was to experience the full abstraction stack of a computer, from low-level (assembly) to high-level (Web API).

[日本語版 README はこちら](./README.md)

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Frontend      │────▶│   Backend API    │────▶│  Assembly CLI   │
│  (Nginx + JS)   │     │  (FastAPI + JWT) │     │  (ARM64 asm)    │
│  Port: 3000     │     │  Port: 8000      │     │  (dev env)      │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

---

## Features

### 🔐 Authentication & Security
- ✅ JWT token-based authentication (30-minute expiry)
- ✅ Password hashing with bcrypt
- ✅ User registration and login
- ✅ Auto-redirect for unauthenticated requests
- ✅ Token validation

### 📊 Attendance Management
- ✅ Clock-in / Clock-out recording
- ✅ Attendance history view
- ✅ Statistics (working days, total hours, etc.)
- ✅ Per-user record management
- ✅ Real-time clock display

### 💼 Frontend
- ✅ Professional business-oriented UI
- ✅ Responsive design (mobile-friendly)
- ✅ Real-time data updates
- ✅ Error handling and notifications
- ✅ Accessibility support

### 🔧 CLI Tool (Assembly)
- ✅ Implemented in ARM64 assembly language
- ✅ Menu-driven interface
- ✅ File-based data persistence
- ✅ Direct system call usage

---

## Requirements

### Prerequisites
- **Docker**: 20.10 or later
- **Docker Compose**: 2.0 or later
- **Architecture**: ARM64 (Apple Silicon Mac) or x86_64

### Recommended Development Environment
- macOS 12.0 or later (Apple Silicon recommended)
- 8 GB RAM or more
- 5 GB free disk space

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/ReoShiozawa/attendance-management.git
cd attendance-management
```

### 2. Start All Services

```bash
docker-compose up --build -d
```

Services launched:
- `assembly`: ARM64 assembly development environment
- `api`: FastAPI backend (port 8000)
- `frontend`: Nginx frontend (port 3000)

### 3. Access

**Frontend (recommended):**
```
http://localhost:3000
```

**API Documentation (Swagger UI):**
```
http://localhost:8000/docs
```

### 4. Default Login

- **Username**: `demo`
- **Password**: `demo123`

Or register a new user from the sign-up screen.

---

## 📁 Project Structure

```
attendance-management/
├── docker-compose.yml              # Service orchestration
├── Dockerfile                      # Assembly dev environment
├── Makefile                        # Assembly build config
├── attendance.s                    # ARM64 assembly CLI tool
├── attendance.dat                  # CLI data file (auto-generated, gitignored)
├── LICENSE                         # MIT License
├── README.md                       # Japanese README
├── README_EN.md                    # This file
│
├── api/                            # Backend API
│   ├── Dockerfile
│   ├── requirements.txt            # Python dependencies
│   ├── app.py                      # FastAPI REST API main
│   └── data/                       # Data directory (gitignored)
│       ├── users.json              # User records (hashed passwords)
│       └── records.json            # Attendance records
│
└── frontend/                       # Frontend
    ├── Dockerfile
    ├── nginx.conf                  # Nginx config (SPA routing)
    ├── login.html                  # Login / register page
    ├── login.js                    # Auth logic
    ├── index.html                  # Main application page
    ├── app.js                      # Attendance management logic
    └── style.css                   # UI styles
```

---

## 🔌 API Reference

> Full interactive docs available at `http://localhost:8000/docs` (Swagger UI).

### Authentication

#### `POST /api/register`
Register a new user.

**Request:**
```json
{ "username": "john", "password": "SecurePass123!" }
```
**Response:**
```json
{ "message": "User registered successfully", "username": "john" }
```

---

#### `POST /api/login`
Authenticate and receive a JWT token.

**Request:**
```json
{ "username": "john", "password": "SecurePass123!" }
```
**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "username": "john"
}
```

---

### Attendance (Requires Auth)

All endpoints below require the header:
```
Authorization: Bearer <token>
```

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/clock-in` | Record clock-in |
| `POST` | `/api/clock-out` | Record clock-out |
| `GET` | `/api/records` | Get all attendance records |
| `GET` | `/api/stats` | Get statistics |

**`GET /api/stats` Response:**
```json
{
  "total_days": 20,
  "total_hours": 160.5,
  "average_hours": 8.025
}
```

---

## 🛠️ Development Guide

### Backend (FastAPI)

```bash
cd api
python3 -m venv venv
source venv/bin/activate   # macOS/Linux
pip install -r requirements.txt
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

**JWT configuration** in `api/app.py`:
```python
SECRET_KEY = "your-secret-key-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
```

### Frontend

Files:
- `login.html` + `login.js` — Authentication screen
- `index.html` + `app.js` — Main application
- `style.css` — Styles

Key notes:
1. JWT token is stored in `localStorage`
2. All API calls use `getAuthHeaders()` to attach the token
3. On 401 errors, the user is automatically logged out

### Assembly CLI (ARM64)

```bash
# Enter the assembly container
docker-compose run --rm assembly

# Build
make

# Debug build
make debug

# Debug with GDB
gdb ./attendance
(gdb) break main
(gdb) run
(gdb) step
```

**Assembly code structure (`attendance.s`):**

| Section | Purpose |
|---------|---------|
| `.data` | String constants, messages |
| `.bss` | Uninitialized data, buffers |
| `.text` | Executable code |

**Key functions:**
- `_start` — Entry point
- `display_menu` — Show menu
- `clock_in` — Record clock-in
- `clock_out` — Record clock-out
- `show_history` — Display history

**System calls used:**
```asm
sys_read    = 63    // Read from stdin
sys_write   = 64    // Write to stdout
sys_openat  = 56    // Open file
sys_close   = 57    // Close file
sys_exit    = 93    // Exit program
```

---

## 📊 Data Format

### Users (`api/data/users.json`)
```json
{
  "demo": {
    "username": "demo",
    "hashed_password": "$2b$12$..."
  }
}
```

### Attendance Records (`api/data/records.json`)
```json
{
  "records": [
    { "user": "demo", "timestamp": "2026-03-02T09:00:00", "type": "IN" },
    { "user": "demo", "timestamp": "2026-03-02T18:30:00", "type": "OUT" }
  ]
}
```

### CLI Data (`attendance.dat`)
```
2026-03-02 09:00:00 IN
2026-03-02 18:30:00 OUT
```

> **Note:** Web and CLI versions do not share data.

---

## 🔒 Security Notes

**This project is for learning purposes. Before deploying to production:**

1. **Change the `SECRET_KEY`** — use a random value from an environment variable:
   ```bash
   export SECRET_KEY="$(openssl rand -hex 32)"
   ```

2. **Restrict CORS origins** — replace `allow_origins=["*"]` with your actual domain.

3. **Enable HTTPS** — use Let's Encrypt or a reverse proxy.

4. **Use a real database** — replace JSON files with PostgreSQL or MySQL.

5. **Add rate limiting** — protect login endpoints from brute-force attacks.

---

## 🧪 Testing

### Manual Test Flow

```bash
# 1. Start all services
docker-compose up -d

# 2. Check container status
docker-compose ps

# 3. Health check
curl http://localhost:8000/docs
curl http://localhost:3000
```

### CLI Test Script

```bash
API_URL="http://localhost:8000"

# Register
curl -X POST "$API_URL/api/register" \
  -H "Content-Type: application/json" \
  -d '{"username":"test_user","password":"testpass123"}'

# Login and get token
TOKEN=$(curl -s -X POST "$API_URL/api/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"test_user","password":"testpass123"}' \
  | jq -r '.access_token')

# Clock in
curl -X POST "$API_URL/api/clock-in" -H "Authorization: Bearer $TOKEN"

# Clock out
curl -X POST "$API_URL/api/clock-out" -H "Authorization: Bearer $TOKEN"

# Get records
curl "$API_URL/api/records" -H "Authorization: Bearer $TOKEN" | jq .

# Get stats
curl "$API_URL/api/stats" -H "Authorization: Bearer $TOKEN" | jq .
```

---

## 🐛 Troubleshooting

### Containers won't start
```bash
docker info                  # Is Docker running?
lsof -i :3000                # Is port 3000 in use?
lsof -i :8000                # Is port 8000 in use?
docker-compose down && docker-compose up --build -d
```

### Can't connect to API
```bash
docker-compose logs api      # Check API logs
curl http://localhost:8000/docs
```

### Login fails
```bash
cat api/data/users.json      # Check user data
# Default: demo / demo123
# Or delete users.json to reset
rm api/data/users.json && docker-compose restart api
```

### Token expires unexpectedly
Change `ACCESS_TOKEN_EXPIRE_MINUTES` in `api/app.py` to extend the token lifetime.

---

## 🤝 Contributing

Issues and Pull Requests are welcome!

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/awesome-feature`)
3. Commit your changes (`git commit -m 'Add awesome feature'`)
4. Push to the branch (`git push origin feature/awesome-feature`)
5. Open a Pull Request

### Development Notes
- Never commit the real `SECRET_KEY` — use environment variables
- `api/data/*.json` may contain personal data — keep it gitignored
- Assembly build artifacts (`attendance`, `attendance.o`, `attendance.dat`) are gitignored by default

---

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

```
Copyright (c) 2026 ReoShiozawa
```

---

## 👤 Author

- GitHub: [@ReoShiozawa](https://github.com/ReoShiozawa)

---

*⭐ If this project was helpful, please give it a star!*
