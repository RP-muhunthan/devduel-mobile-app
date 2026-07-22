"""
pages/__init__.py – Re-export all page objects for convenience
"""
from .base_page       import BasePage
from .splash_page     import SplashPage
from .login_page      import LoginPage
from .register_page   import RegisterPage
from .home_page       import HomePage
from .battle_page     import BattlePage
from .problems_page   import ProblemsPage
from .leaderboard_page import LeaderboardPage, ProfilePage

__all__ = [
    "BasePage",
    "SplashPage",
    "LoginPage",
    "RegisterPage",
    "HomePage",
    "BattlePage",
    "ProblemsPage",
    "LeaderboardPage",
    "ProfilePage",
]
