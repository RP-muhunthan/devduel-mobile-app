import uuid
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional

from database import get_db
from auth import get_current_user
from schemas import BattleResponse, CompleteBattleRequest
import models

router = APIRouter(prefix="/battles", tags=["Battles"])


def _battle_to_response(b: models.Battle) -> BattleResponse:
    return BattleResponse(
        id=b.id,
        player1Id=b.player1_id,
        player2Id=b.player2_id,
        problemId=b.problem_id,
        status=b.status,
        winnerId=b.winner_id,
        createdAt=b.created_at.isoformat() if b.created_at else "",
    )


# ─── Matchmaking Queue ───────────────────────────────────────────────────────

@router.post("/queue/join", status_code=200)
def join_queue(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    existing = db.query(models.MatchmakingQueue).filter(
        models.MatchmakingQueue.user_id == current_user.id
    ).first()
    if not existing:
        db.add(models.MatchmakingQueue(user_id=current_user.id))
        db.commit()
    return {"message": "Joined queue"}


@router.delete("/queue/leave", status_code=200)
def leave_queue(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    db.query(models.MatchmakingQueue).filter(
        models.MatchmakingQueue.user_id == current_user.id
    ).delete()
    db.commit()
    return {"message": "Left queue"}


@router.post("/queue/match", status_code=200)
def try_to_match(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Try to find another player in the queue and create a battle."""
    # Find any other player in queue
    opponent_entry = db.query(models.MatchmakingQueue).filter(
        models.MatchmakingQueue.user_id != current_user.id
    ).first()

    if not opponent_entry:
        return {"message": "No opponent found yet", "matched": False}

    opponent_id = opponent_entry.user_id

    # Pick a random active problem
    problem = db.query(models.Problem).first()
    problem_id = problem.id if problem else "1"

    # Create battle
    battle = models.Battle(
        id=str(uuid.uuid4()),
        player1_id=current_user.id,
        player2_id=opponent_id,
        problem_id=problem_id,
        status="active",
    )
    db.add(battle)

    # Remove both from queue
    db.query(models.MatchmakingQueue).filter(
        models.MatchmakingQueue.user_id.in_([current_user.id, opponent_id])
    ).delete(synchronize_session=False)

    db.commit()
    db.refresh(battle)
    return {"message": "Match found!", "matched": True, "battle": _battle_to_response(battle)}


# ─── Active Battle ────────────────────────────────────────────────────────────

@router.get("/active", response_model=Optional[BattleResponse])
def get_active_battle(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Get the current user's active battle (if any)."""
    battle = db.query(models.Battle).filter(
        models.Battle.status == "active",
        (
            (models.Battle.player1_id == current_user.id) |
            (models.Battle.player2_id == current_user.id)
        ),
    ).first()

    return _battle_to_response(battle) if battle else None


# ─── Simulate Battle ─────────────────────────────────────────────────────────

@router.post("/simulate", response_model=BattleResponse, status_code=201)
def simulate_battle(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    """Create a simulated battle against a BOT opponent."""
    problem = db.query(models.Problem).first()
    problem_id = problem.id if problem else "1"

    battle = models.Battle(
        id=str(uuid.uuid4()),
        player1_id=current_user.id,
        player2_id="BOT_OPPONENT",
        problem_id=problem_id,
        status="active",
    )
    db.add(battle)
    db.commit()
    db.refresh(battle)
    return _battle_to_response(battle)


# ─── Complete Battle ──────────────────────────────────────────────────────────

@router.put("/{battle_id}/complete", response_model=BattleResponse)
def complete_battle(
    battle_id: str,
    req: CompleteBattleRequest,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user),
):
    battle = db.query(models.Battle).filter(models.Battle.id == battle_id).first()
    if not battle:
        raise HTTPException(status_code=404, detail="Battle not found")

    battle.status = "completed"
    battle.winner_id = req.winner_id

    # Update stats for both players
    for player_id in [battle.player1_id, battle.player2_id]:
        if player_id == "BOT_OPPONENT":
            continue
        user = db.query(models.User).filter(models.User.id == player_id).first()
        if user:
            user.battles = user.battles + 1
            if player_id == req.winner_id:
                user.wins = user.wins + 1

    db.commit()
    db.refresh(battle)
    return _battle_to_response(battle)
