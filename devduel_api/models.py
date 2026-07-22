import json
from sqlalchemy import Column, String, Integer, Text, DateTime, ForeignKey
from sqlalchemy.sql import func
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True, index=True)  # UUID
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    bio = Column(String, default="Adventurous Coder 🚀")
    xp = Column(Integer, default=0)
    level = Column(Integer, default=1)
    rank = Column(String, default="Newbie")
    wins = Column(Integer, default=0)
    battles = Column(Integer, default=0)
    problems = Column(Integer, default=0)
    streak = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class Problem(Base):
    __tablename__ = "problems"

    id = Column(String, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    difficulty = Column(String, default="easy")  # easy | medium | hard
    starter_codes = Column(Text, default="{}")   # JSON string
    test_cases = Column(Text, default="[]")      # JSON string
    points = Column(Integer, default=100)

    def get_starter_codes(self) -> dict:
        return json.loads(self.starter_codes)

    def get_test_cases(self) -> list:
        return json.loads(self.test_cases)


class Battle(Base):
    __tablename__ = "battles"

    id = Column(String, primary_key=True, index=True)  # UUID
    player1_id = Column(String, ForeignKey("users.id"), nullable=False)
    player2_id = Column(String, nullable=False)  # can be 'BOT_OPPONENT'
    problem_id = Column(String, ForeignKey("problems.id"), nullable=False)
    status = Column(String, default="searching")  # searching | active | completed
    winner_id = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class MatchmakingQueue(Base):
    __tablename__ = "matchmaking_queue"

    user_id = Column(String, ForeignKey("users.id"), primary_key=True)
    joined_at = Column(DateTime(timezone=True), server_default=func.now())
