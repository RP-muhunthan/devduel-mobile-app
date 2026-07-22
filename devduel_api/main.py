from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import engine
import models
from routers import auth_router, users_router, problems_router, battles_router

# ─── Create all tables ────────────────────────────────────────────────────────
models.Base.metadata.create_all(bind=engine)

# ─── App Setup ───────────────────────────────────────────────────────────────
app = FastAPI(
    title="DevDuel API",
    description="REST API backend for DevDuel — Real-Time Coding Battles",
    version="1.0.0",
)

# Allow Flutter app (Android emulator uses 10.0.2.2, web uses localhost)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tighten in production
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Routers ─────────────────────────────────────────────────────────────────
app.include_router(auth_router.router)
app.include_router(users_router.router)
app.include_router(problems_router.router)
app.include_router(battles_router.router)


# ─── Health Check ─────────────────────────────────────────────────────────────
@app.get("/", tags=["Health"])
def root():
    return {"status": "ok", "message": "DevDuel API is running 🚀"}


@app.get("/health", tags=["Health"])
def health():
    return {"status": "healthy"}
