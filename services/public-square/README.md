# Public Square API

Forum API for posts, comments, and discussions with user authentication.

## Overview

Public Square is a RESTful API backend for a public forum/blog platform. It provides:

- User registration and authentication (JWT)
- Posts (threads/articles)
- Comments on posts
- Rate limiting to prevent abuse
- SQLite database (lightweight, file-based)

## Technology Stack

- **FastAPI**: Modern Python web framework
- **SQLAlchemy**: SQL ORM for database operations
- **SQLite**: Lightweight database (single file)
- **FastAPI-Users**: Authentication and user management
- **Pydantic**: Data validation
- **SlowAPI**: Rate limiting
- **JWT**: Token-based authentication

## Prerequisites

- Docker and Docker Compose
- Tailscale deployed (for Funnel feature)

## Configuration

### Step 1: Environment Variables

```bash
cp .env.example .env
nano .env
```

Generate a secure JWT secret:
```bash
openssl rand -hex 32
```

Update `.env`:
```env
JWT_SECRET=<your-generated-secret>
CORS_ORIGINS=https://yourusername.github.io
```

### Step 2: Build and Deploy

```bash
# Build the Docker image
docker compose build

# Start the service
docker compose up -d

# View logs
docker compose logs -f
```

### Step 3: Verify Deployment

```bash
# Check service health
curl http://localhost:8000/health

# View API docs
# Visit: http://localhost:8000/docs
```

### Step 4: Expose Publicly (Optional)

Use Tailscale Funnel to make the API publicly accessible:

```bash
# Enable Funnel for port 8000
docker exec tailscale tailscale funnel 8000

# API will be available at:
# https://fart-pi.your-tailnet.ts.net:8000
```

## API Endpoints

### System
- `GET /` - API information
- `GET /health` - Health check
- `GET /docs` - Interactive API documentation (Swagger UI)
- `GET /redoc` - Alternative API documentation (ReDoc)

### Authentication (TODO: Implement routers)
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login and get JWT token
- `POST /auth/logout` - Logout
- `GET /auth/me` - Get current user info

### Posts (TODO: Implement routers)
- `GET /posts` - List all posts (public)
- `POST /posts` - Create new post (authenticated)
- `GET /posts/{id}` - Get single post (public)
- `PUT /posts/{id}` - Update post (author only)
- `DELETE /posts/{id}` - Delete post (author only)

### Comments (TODO: Implement routers)
- `GET /posts/{id}/comments` - List comments on a post (public)
- `POST /posts/{id}/comments` - Add comment (authenticated)
- `PUT /comments/{id}` - Update comment (author only)
- `DELETE /comments/{id}` - Delete comment (author only)

## Database

### Location
- File: `./data/public_square.db`
- Type: SQLite (single file database)

### Schema

**Users Table:**
- id, email, hashed_password, username
- is_active, is_verified, is_superuser
- created_at

**Posts Table:**
- id, title, content, author_id
- created_at, updated_at, is_published

**Comments Table:**
- id, content, post_id, author_id
- created_at, updated_at

### Backup

Simply copy the database file:
```bash
cp data/public_square.db data/public_square.db.backup
```

## Security Features

### Implemented
- JWT token authentication
- Password hashing (bcrypt)
- CORS configuration
- Rate limiting (SlowAPI)
- Input validation (Pydantic)
- SQL injection protection (SQLAlchemy ORM)

### Rate Limits (TODO: Configure in routers)
- Login: 5 attempts/minute
- Register: 3 attempts/hour
- Create post: 10/minute
- Create comment: 20/minute

## Development

### Local Development

For local development without Docker:

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Project Structure

```
public-square/
├── app/
│   ├── main.py           # FastAPI application entry point
│   ├── config.py         # Configuration and settings
│   ├── database.py       # Database connection and session
│   ├── models.py         # SQLAlchemy ORM models
│   ├── schemas.py        # Pydantic validation schemas
│   ├── auth.py           # Authentication setup
│   └── routers/          # API route handlers (TODO)
│       ├── auth.py       # Auth endpoints
│       ├── posts.py      # Post endpoints
│       └── comments.py   # Comment endpoints
├── data/                 # SQLite database (not in Git)
├── docker-compose.yml    # Container orchestration
├── Dockerfile            # Container image definition
├── requirements.txt      # Python dependencies
└── README.md             # This file
```

## Monitoring

### Check Status

```bash
# Container status
docker compose ps

# View logs
docker compose logs -f

# Check health
curl http://localhost:8000/health
```

### Database Size

```bash
du -h data/public_square.db
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker compose logs

# Rebuild image
docker compose build --no-cache
docker compose up -d
```

### Database Issues

```bash
# Stop service
docker compose down

# Backup current database
cp data/public_square.db data/public_square.db.backup

# Remove database and recreate
rm data/public_square.db
docker compose up -d
```

### Permission Errors

```bash
# Fix data directory permissions
sudo chown -R $USER:$USER data/
```

## Next Steps

1. Implement router modules (auth, posts, comments)
2. Add rate limiting to endpoints
3. Test authentication flow
4. Connect frontend to API
5. Enable Tailscale Funnel for public access

## References

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [FastAPI-Users](https://fastapi-users.github.io/fastapi-users/)
- [SQLAlchemy](https://docs.sqlalchemy.org/)
- [Pydantic](https://docs.pydantic.dev/)
