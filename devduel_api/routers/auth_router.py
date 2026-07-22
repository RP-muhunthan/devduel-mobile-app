import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from database import get_db
from auth import hash_password, verify_password, create_access_token
from schemas import RegisterRequest, LoginRequest, TokenResponse, UserResponse
import models

router = APIRouter(prefix="/auth", tags=["Authentication"])


def _user_to_response(user: models.User) -> UserResponse:
    return UserResponse(
        uid=user.id,
        email=user.email,
        username=user.username,
        bio=user.bio,
        xp=user.xp,
        level=user.level,
        rank=user.rank,
        wins=user.wins,
        battles=user.battles,
        problems=user.problems,
        streak=user.streak,
    )


@router.post("/register", response_model=TokenResponse, status_code=201)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    email = req.email.strip().lower()
    username = req.username.strip()
    password = req.password

    # Input validations
    if not email or "@" not in email:
        raise HTTPException(status_code=400, detail="Invalid email address")
    if not username:
        raise HTTPException(status_code=400, detail="Username cannot be empty")
    if len(password) < 6:
        raise HTTPException(status_code=400, detail="Password must be at least 6 characters")

    # Check email uniqueness
    if db.query(models.User).filter(models.User.email == email).first():
        raise HTTPException(status_code=400, detail="Email already registered")
    # Check username uniqueness
    if db.query(models.User).filter(models.User.username == username).first():
        raise HTTPException(status_code=400, detail="Username already taken")

    user = models.User(
        id=str(uuid.uuid4()),
        email=email,
        username=username,
        password_hash=hash_password(password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_access_token(user.id)
    return TokenResponse(access_token=token, user=_user_to_response(user))


@router.post("/login", response_model=TokenResponse)
def login(req: LoginRequest, db: Session = Depends(get_db)):
    email = req.email.strip().lower()
    password = req.password

    if not email or "@" not in email:
        raise HTTPException(status_code=400, detail="Invalid email address")
    if not password:
        raise HTTPException(status_code=400, detail="Password cannot be empty")

    user = db.query(models.User).filter(
        models.User.email == email
    ).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email not registered",
        )

    if not verify_password(password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect password",
        )

    token = create_access_token(user.id)
    return TokenResponse(access_token=token, user=_user_to_response(user))
