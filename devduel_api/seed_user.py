import sys
import os
import uuid

# Add devduel_api to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import SessionLocal
import models
import bcrypt

def seed():
    db = SessionLocal()
    try:
        users_to_seed = [
            {
                "email": "purushothamannirt@gmail.com",
                "username": "Purushothaman",
                "password": "purushothaman@1977",
                "xp": 1500,
                "level": 3,
                "rank": "Coder",
                "wins": 5,
                "battles": 10,
                "problems": 8,
                "streak": 3,
            },
            {
                "email": "google_user@devduel.com",
                "username": "GoogleUser",
                "password": "GoogleUser123!",
                "xp": 100,
                "level": 1,
                "rank": "Newbie",
                "wins": 0,
                "battles": 0,
                "problems": 0,
                "streak": 0,
            }
        ]

        for u_data in users_to_seed:
            email = u_data["email"]
            user = db.query(models.User).filter(models.User.email == email).first()
            if user:
                print(f"User {email} already exists in DB.")
                continue
                
            hashed_pw = bcrypt.hashpw(u_data["password"].encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
            
            new_user = models.User(
                id=str(uuid.uuid4()),
                email=email,
                username=u_data["username"],
                password_hash=hashed_pw,
                xp=u_data["xp"],
                level=u_data["level"],
                rank=u_data["rank"],
                wins=u_data["wins"],
                battles=u_data["battles"],
                problems=u_data["problems"],
                streak=u_data["streak"],
            )
            db.add(new_user)
            db.commit()
            print(f"User {email} successfully seeded to DB.")
    finally:
        db.close()

if __name__ == "__main__":
    seed()
