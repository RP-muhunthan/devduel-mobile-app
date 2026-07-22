from pydantic import BaseModel, EmailStr
from typing import Optional, Dict, List, Any
from datetime import datetime


# ─── Auth Schemas ───────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    email: str
    username: str
    password: str


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: "UserResponse"


# ─── User Schemas ────────────────────────────────────────────────────────────

class UserResponse(BaseModel):
    uid: str
    email: str
    username: str
    bio: str
    xp: int
    level: int
    rank: str
    wins: int
    battles: int
    problems: int
    streak: int

    class Config:
        from_attributes = True


class UpdateProfileRequest(BaseModel):
    username: Optional[str] = None
    bio: Optional[str] = None


class UpdateXPRequest(BaseModel):
    points: int


# ─── Problem Schemas ─────────────────────────────────────────────────────────

class TestCaseSchema(BaseModel):
    input: str
    expectedOutput: str


class ProblemResponse(BaseModel):
    id: str
    title: str
    description: str
    difficulty: str
    starterCodes: Dict[str, str]
    testCases: List[TestCaseSchema]
    points: int

    class Config:
        from_attributes = True


# ─── Battle Schemas ───────────────────────────────────────────────────────────

class BattleResponse(BaseModel):
    id: str
    player1Id: str
    player2Id: str
    problemId: str
    status: str
    winnerId: Optional[str]
    createdAt: str

    class Config:
        from_attributes = True


class CompleteBattleRequest(BaseModel):
    winner_id: str


# ─── Resolve forward references ───────────────────────────────────────────────
TokenResponse.model_rebuild()
