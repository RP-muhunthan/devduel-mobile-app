import uuid
import random
from locust import HttpUser, task, between

class DevDuelUser(HttpUser):
    wait_time = between(1, 3)
    
    def on_start(self):
        self.token = None
        self.user_id = None
        # Generate random unique credentials for this virtual user session
        self.username = f"user_{uuid.uuid4().hex[:8]}"
        self.email = f"{self.username}@test.com"
        self.password = "password123"
        self.headers = {}
        
        # 1. Register test case (Screen: Auth/Register)
        with self.client.post("/auth/register", json={
            "email": self.email,
            "username": self.username,
            "password": self.password
        }, catch_response=True, name="1. Register") as response:
            if response.status_code == 201:
                data = response.json()
                self.token = data.get("access_token")
                self.headers = {"Authorization": f"Bearer {self.token}"}
                response.success()
            else:
                response.failure(f"Failed to register: {response.text}")

    @task(3)
    def test_get_me(self):
        # 2. Get Profile (Screen: Profile)
        if self.token:
            self.client.get("/users/me", headers=self.headers, name="2. Get Profile")

    @task(2)
    def test_update_profile(self):
        # 3. Update Profile (Screen: Profile Edit)
        if self.token:
            self.client.put("/users/me", json={
                "bio": f"Updated bio {random.randint(1, 1000)}"
            }, headers=self.headers, name="3. Update Profile")
            
    @task(3)
    def test_leaderboard(self):
        # 4. Get Leaderboard (Screen: Leaderboard)
        self.client.get("/users/leaderboard", name="4. Get Leaderboard")

    @task(2)
    def test_simulate_battle(self):
        # 5. Simulate Battle (Screen: Battle/Problems)
        if self.token:
            with self.client.post("/battles/simulate", headers=self.headers, catch_response=True, name="5. Simulate Battle") as response:
                if response.status_code == 201:
                    battle_id = response.json().get("id")
                    if battle_id:
                        # 6. Complete Battle (Screen: Battle Result)
                        self.client.put(f"/battles/{battle_id}/complete", json={
                            "winner_id": "BOT_OPPONENT"
                        }, headers=self.headers, name="6. Complete Battle")
                        
    @task(2)
    def test_update_xp(self):
        # 7. Update XP (Screen: Progress)
        if self.token:
            self.client.put("/users/me/xp", json={
                "points": 10
            }, headers=self.headers, name="7. Update XP")

    @task(1)
    def test_queue_flow(self)
        # 8, 9, 10. Queue flow (Screen: Home/Matchmaking)
        if self.token:
            self.client.post("/battles/queue/join", headers=self.headers, name="8. Join Queue")
            self.client.post("/battles/queue/match", headers=self.headers, name="9. Matchmaking")
            self.client.delete("/battles/queue/leave", headers=self.headers, name="10. Leave Queue")

    @task(1)
    def test_health(self):
        # 11. Health Check (Screen: Splash)
        self.client.get("/health", name="11. Health Check")

    @task(1)
    def test_get_problems(self):
        # 12. Problems list (Screen: Problems)
        if self.token:
            self.client.get("/problems", headers=self.headers, name="12. Get Problems")
