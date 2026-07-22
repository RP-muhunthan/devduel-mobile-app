from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from auth import get_current_user
from schemas import UserResponse, UpdateProfileRequest, UpdateXPRequest
import models

router = APIRouter(prefix="/users", tags=["Users"])


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


def _compute_rank(xp: int) -> tuple[str, int]:
    """Returns (rank_name, level) based on XP."""
    thresholds = [
        (0, "Newbie", 1),
        (100, "Apprentice", 2),
        (300, "Coder", 3),
        (600, "Warrior", 4),
        (1000, "Elite", 5),
        (2000, "Master", 6),
        (4000, "Grandmaster", 7),
    ]
    rank, level = "Newbie", 1
    for min_xp, r, lv in thresholds:
        if xp >= min_xp:
            rank, level = r, lv
    return rank, level


@router.get("/me", response_model=UserResponse)
def get_me(current_user: models.User = Depends(get_current_user)):
    return _user_to_response(current_user)


@router.put("/me", response_model=UserResponse)
def update_profile(
    req: UpdateProfileRequest,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    if req.username:
        existing = db.query(models.User).filter(
            models.User.username == req.username,
            models.User.id != current_user.id,
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="Username already taken")
        current_user.username = req.username
    if req.bio is not None:
        current_user.bio = req.bio

    db.commit()
    db.refresh(current_user)
    return _user_to_response(current_user)


@router.put("/me/xp", response_model=UserResponse)
def update_xp(
    req: UpdateXPRequest,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    current_user.xp = current_user.xp + req.points
    rank, level = _compute_rank(current_user.xp)
    current_user.rank = rank
    current_user.level = level

    db.commit()
    db.refresh(current_user)
    return _user_to_response(current_user)


@router.get("/leaderboard", response_model=list[UserResponse])
def get_leaderboard(db: Session = Depends(get_db)):
    users = (
        db.query(models.User)
        .order_by(models.User.xp.desc())
        .limit(20)
        .all()
    )
    return [_user_to_response(u) for u in users]
