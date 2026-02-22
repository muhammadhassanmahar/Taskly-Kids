from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import user_routes, task_routes, progress_routes

# ==========================================================
# APP INITIALIZATION
# ==========================================================

app = FastAPI(
    title="Parent-Child Task App API",
    description="API for managing tasks between parents and children",
    version="1.0.0"
)

# ==========================================================
# CORS CONFIGURATION
# ==========================================================

# Flutter Web / Chrome / Localhost support
origins = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:8080",
    "http://127.0.0.1",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ✅ Web development ke liye
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================================
# ROUTES
# ==========================================================

# 🔐 AUTH ROUTES
app.include_router(
    user_routes.router,
    prefix="/auth",
    tags=["Auth"]
)

# 📌 TASK ROUTES
app.include_router(
    task_routes.router,
    prefix="/tasks",
    tags=["Tasks"]
)

# 📊 PROGRESS ROUTES
app.include_router(
    progress_routes.router,
    prefix="/progress",
    tags=["Progress"]
)

# ==========================================================
# ROOT ENDPOINT
# ==========================================================

@app.get("/", tags=["Root"])
async def root():
    return {
        "message": "Parent-Child Task API is running 🚀",
        "status": "OK",
        "available_routes": {
            "auth": "/auth",
            "tasks": "/tasks",
            "progress": "/progress",
            "docs": "/docs"
        }
    }
