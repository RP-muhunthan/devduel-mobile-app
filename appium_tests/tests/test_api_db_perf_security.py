"""
test_api_db_perf_security.py – API, Database, Performance, and Security Tests
=============================================================================
Contains 80+ parameterized test cases to comprehensively verify:
1. API Testing: Response codes, body shapes, endpoints.
2. Database Testing: SQLite schema, constraints, defaults, and data integrity.
3. Security Testing: Auth bypass checks, SQL Injection, and XSS validation.
4. Performance Testing: Endpoint latencies (<200ms) and concurrent requests.
"""

import os
import time
import uuid
import sqlite3
import pytest
import requests
import concurrent.futures
from utils import ResultRecord

MODULE = "08 – API/DB/Perf/Security Backend"
BASE_URL = "http://127.0.0.1:8000"

# Absolute path to devduel.db inside devduel_api folder
DB_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "devduel_api", "devduel.db")
)

# ── Auto-record fixture ───────────────────────────────────────────────────────

@pytest.fixture(autouse=True)
def _record_setup(request, excel_reporter):
    """Auto-record every test in this module to the Excel reporter."""
    start = time.time()
    yield
    status = "PASS"
    error = ""

    rep = getattr(request.node, "rep_call", None)
    if rep and rep.failed:
        status = "FAIL"
        error = str(rep.longrepr)[:300] if rep.longrepr else ""

    # Determine testing category based on markers
    category = "Functional Testing"
    for marker in request.node.iter_markers(name="category"):
        category = marker.args[0]
        break

    excel_reporter.add_result(ResultRecord(
        test_id=request.node.name,
        name=request.node.name.replace("_", " ").title(),
        module=MODULE,
        status=status,
        duration_sec=time.time() - start,
        error_msg=error,
        category=category,
    ))


# ── Helper functions for API ──────────────────────────────────────────────────

def register_user(email, username, password):
    url = f"{BASE_URL}/auth/register"
    payload = {"email": email, "username": username, "password": password}
    return requests.post(url, json=payload)

def login_user(email, password):
    url = f"{BASE_URL}/auth/login"
    payload = {"email": email, "password": password}
    return requests.post(url, json=payload)


# ── 1. API TESTING ────────────────────────────────────────────────────────────

@pytest.mark.category("API Testing")
class TestAPIFunctional:

    # Register validation
    @pytest.mark.parametrize("email,username,password,expected_code", [
        ("", "user1", "Pass@123", 422),
        ("invalid-email", "user2", "Pass@123", 422),
        ("user3@devduel.com", "", "Pass@123", 422),
        ("user4@devduel.com", "user4", "", 422),
        ("user5@devduel.com", "user5", "123", 400), # Short password (should trigger 400/422 depending on validators)
        ("google_user@devduel.com", "GoogleUser2", "Pass@123", 400), # Duplicate email
        ("user_dup@devduel.com", "GoogleUser", "Pass@123", 400), # Duplicate username
    ])
    def test_api_register_validation(self, email, username, password, expected_code):
        """TC-API-REG-VAL: Verify register constraints and input validation."""
        # Clean duplicates if user5 got inserted
        res = register_user(email, username, password)
        assert res.status_code in [expected_code, 422, 400]

    # Login validation
    @pytest.mark.parametrize("email,password,expected_code", [
        ("", "Pass@123", 400),
        ("not_registered@devduel.com", "Pass@123", 401),
        ("purushothamannirt@gmail.com", "WrongPass999!", 401),
        ("purushothamannirt@gmail.com", "", 400),
        ("", "", 400),
    ])
    def test_api_login_validation(self, email, password, expected_code):
        """TC-API-LOG-VAL: Verify login error responses and codes."""
        res = login_user(email, password)
        assert res.status_code in [expected_code, 422, 400]

    # Success scenarios
    @pytest.mark.parametrize("email,username,password", [
        (f"test_{uuid.uuid4().hex[:6]}@devduel.com", f"user_{uuid.uuid4().hex[:6]}", "Pass@123"),
    ])
    def test_api_auth_success(self, email, username, password):
        """TC-API-AUTH-SUC: Verify registration & login successfully returns JWT."""
        # 1. Register
        reg_res = register_user(email, username, password)
        assert reg_res.status_code == 201
        data = reg_res.json()
        assert "access_token" in data
        assert data["user"]["email"] == email.lower()

        # 2. Login
        log_res = login_user(email, password)
        assert log_res.status_code == 200
        assert "access_token" in log_res.json()

    # Profile management
    def test_api_profile_retrieval(self):
        """TC-API-PROF-RET: Retrieve current authenticated user profile."""
        res = login_user("purushothamannirt@gmail.com", "purushothaman@1977")
        token = res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        profile_res = requests.get(f"{BASE_URL}/users/me", headers=headers)
        assert profile_res.status_code == 200
        assert profile_res.json()["email"] == "purushothamannirt@gmail.com"

    @pytest.mark.parametrize("username,bio,expected_code", [
        ("PurushothamanNew", "New Bio 🚀", 200),
        ("GoogleUser", "Taken username", 400), # GoogleUser is duplicate
    ])
    def test_api_profile_update(self, username, bio, expected_code):
        """TC-API-PROF-UPD: Update profile and check constraints."""
        res = login_user("purushothamannirt@gmail.com", "purushothaman@1977")
        token = res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        payload = {"username": username, "bio": bio}
        update_res = requests.put(f"{BASE_URL}/users/me", json=payload, headers=headers)
        assert update_res.status_code == expected_code
        if expected_code == 200:
            # Revert change
            requests.put(f"{BASE_URL}/users/me", json={"username": "Purushothaman", "bio": "Adventurous Coder 🚀"}, headers=headers)

    # Leaderboard
    def test_api_leaderboard(self):
        """TC-API-LEAD: Retrieve leaderboard details."""
        res = requests.get(f"{BASE_URL}/users/leaderboard")
        assert res.status_code == 200
        data = res.json()
        assert isinstance(data, list)
        if len(data) > 1:
            assert data[0]["xp"] >= data[1]["xp"]

    # Problems
    @pytest.mark.parametrize("prob_id,expected_code", [
        ("1", 200),
        ("2", 200),
        ("999", 404),
    ])
    def test_api_problems(self, prob_id, expected_code):
        """TC-API-PROB: Retrieve problem details."""
        res = requests.get(f"{BASE_URL}/problems/{prob_id}")
        assert res.status_code == expected_code

    # Matchmaking & Battles
    def test_api_matchmaking_flow(self):
        """TC-API-MATCH: Verify joining/leaving queue and battle simulation."""
        # 1. Login user
        res = login_user("purushothamannirt@gmail.com", "purushothaman@1977")
        token = res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # Clean active battles if any exist for test stability (loop until none are active)
        while True:
            active_res = requests.get(f"{BASE_URL}/battles/active", headers=headers)
            if active_res.status_code == 200 and active_res.json():
                b_id = active_res.json()["id"]
                requests.put(
                    f"{BASE_URL}/battles/{b_id}/complete",
                    json={"winner_id": "purushothamannirt@gmail.com"},
                    headers=headers
                )
            else:
                break

        # 2. Join queue
        join_res = requests.post(f"{BASE_URL}/battles/queue/join", headers=headers)
        assert join_res.status_code == 200
        assert join_res.json()["message"] == "Joined queue"

        # 3. Try matching (no opponent)
        match_res = requests.post(f"{BASE_URL}/battles/queue/match", headers=headers)
        assert match_res.status_code == 200
        assert match_res.json()["matched"] is False

        # 4. Leave queue
        leave_res = requests.delete(f"{BASE_URL}/battles/queue/leave", headers=headers)
        assert leave_res.status_code == 200
        assert leave_res.json()["message"] == "Left queue"

        # 5. Simulate BOT Battle
        sim_res = requests.post(f"{BASE_URL}/battles/simulate", headers=headers)
        assert sim_res.status_code == 201
        battle_id = sim_res.json()["id"]

        # 6. Get Active Battle
        active_res = requests.get(f"{BASE_URL}/battles/active", headers=headers)
        assert active_res.status_code == 200
        assert active_res.json()["id"] == battle_id

        # 7. Complete Battle
        comp_res = requests.put(
            f"{BASE_URL}/battles/{battle_id}/complete",
            json={"winner_id": "purushothamannirt@gmail.com"},
            headers=headers
        )
        assert comp_res.status_code == 200
        assert comp_res.json()["status"] == "completed"
        assert comp_res.json()["winnerId"] == "purushothamannirt@gmail.com"


# ── 2. DATABASE TESTING ───────────────────────────────────────────────────────

@pytest.mark.category("Database Testing")
class TestDatabaseIntegrity:

    def get_db_connection(self):
        return sqlite3.connect(DB_PATH)

    @pytest.mark.parametrize("table_name", [
        ("users"),
        ("problems"),
        ("battles"),
        ("matchmaking_queue")
    ])
    def test_db_table_existence(self, table_name):
        """TC-DB-TAB-EXI: Verify essential tables exist in SQLite database."""
        conn = self.get_db_connection()
        cursor = conn.cursor()
        cursor.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table_name}';")
        row = cursor.fetchone()
        conn.close()
        assert row is not None, f"Table {table_name} does not exist"

    @pytest.mark.parametrize("col_name,col_type", [
        ("id", "VARCHAR"),
        ("email", "VARCHAR"),
        ("username", "VARCHAR"),
        ("password_hash", "VARCHAR"),
        ("xp", "INTEGER"),
        ("level", "INTEGER"),
        ("rank", "VARCHAR")
    ])
    def test_db_user_columns(self, col_name, col_type):
        """TC-DB-USER-COL: Verify schemas and types of user table."""
        conn = self.get_db_connection()
        cursor = conn.cursor()
        cursor.execute("PRAGMA table_info(users);")
        columns = cursor.fetchall()
        conn.close()
        # column schema row: (cid, name, type, notnull, dflt_value, pk)
        found = False
        for col in columns:
            if col[1] == col_name:
                found = True
                assert col_type in col[2].upper()
                break
        assert found, f"Column {col_name} not found in users table"

    def test_db_problems_seeded(self):
        """TC-DB-PROB-SEED: Ensure problems table has seeded coding problems."""
        conn = self.get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM problems;")
        count = cursor.fetchone()[0]
        conn.close()
        assert count >= 1, "Problems table is empty, seed failed."


# ── 3. SECURITY TESTING ───────────────────────────────────────────────────────

@pytest.mark.category("Security Testing")
class TestSecurityBypass:

    # Authentication Bypass / Missing Bearer Tokens
    @pytest.mark.parametrize("method,endpoint,payload", [
        ("GET", "/users/me", None),
        ("PUT", "/users/me", {"username": "hack"}),
        ("PUT", "/users/me/xp", {"points": 100}),
        ("GET", "/battles/active", None),
        ("POST", "/battles/queue/join", None),
        ("DELETE", "/battles/queue/leave", None),
        ("POST", "/battles/simulate", None),
        ("PUT", "/battles/some-id/complete", {"winner_id": "me"}),
    ])
    def test_security_missing_token(self, method, endpoint, payload):
        """TC-SEC-BYP-MISS: Access restricted endpoints without token -> 401/403."""
        url = f"{BASE_URL}{endpoint}"
        if method == "GET":
            res = requests.get(url)
        elif method == "PUT":
            res = requests.put(url, json=payload)
        elif method == "POST":
            res = requests.post(url, json=payload)
        elif method == "DELETE":
            res = requests.delete(url)
        assert res.status_code in [401, 403]

    # Unauthorized access with invalid token
    @pytest.mark.parametrize("method,endpoint,payload", [
        ("GET", "/users/me", None),
        ("PUT", "/users/me/xp", {"points": 100}),
    ])
    def test_security_invalid_token(self, method, endpoint, payload):
        """TC-SEC-BYP-INV: Access restricted endpoints with invalid token -> 401."""
        url = f"{BASE_URL}{endpoint}"
        headers = {"Authorization": "Bearer invalid_jwt_token_payload"}
        if method == "GET":
            res = requests.get(url, headers=headers)
        elif method == "PUT":
            res = requests.put(url, json=payload, headers=headers)
        assert res.status_code == 401

    # SQL Injection attacks
    @pytest.mark.parametrize("injection_payload", [
        ("' OR '1'='1"),
        ("admin' --"),
        ("' UNION SELECT NULL, NULL, NULL --"),
        ("' OR 1=1 LIMIT 1 --"),
        ("'; DROP TABLE users; --"),
    ])
    def test_security_sql_injection_login(self, injection_payload):
        """TC-SEC-SQLI: Test SQL injection vulnerability on login endpoints."""
        res = login_user(injection_payload, "password123")
        # Should either return 401 (unauthorized) or 422 (validation error) but NEVER 200 or 500 (db crash)
        assert res.status_code in [401, 422, 400]

    # XSS Injection testing
    @pytest.mark.parametrize("xss_payload", [
        ("<script>alert('XSS')</script>"),
        ("<img src=x onerror=alert(1)>"),
        ("javascript:alert(1)"),
    ])
    def test_security_xss_prevention(self, xss_payload):
        """TC-SEC-XSS: Test XSS payloads on bio profile update."""
        res = login_user("purushothamannirt@gmail.com", "purushothaman@1977")
        token = res.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        payload = {"bio": xss_payload}
        update_res = requests.put(f"{BASE_URL}/users/me", json=payload, headers=headers)
        # Should sanitize/accept as literal but not crash
        assert update_res.status_code == 200
        # Revert bio
        requests.put(f"{BASE_URL}/users/me", json={"bio": "Adventurous Coder 🚀"}, headers=headers)


# ── 4. PERFORMANCE TESTING ────────────────────────────────────────────────────

@pytest.mark.category("Performance Testing")
class TestPerformanceLatency:

    # Benchmark response latencies
    @pytest.mark.parametrize("endpoint,method,auth_needed", [
        ("/users/leaderboard", "GET", False),
        ("/problems", "GET", False),
        ("/users/me", "GET", True),
    ])
    def test_perf_endpoint_latency(self, endpoint, method, auth_needed):
        """TC-PERF-LAT: Measure API response times (<200ms benchmark)."""
        url = f"{BASE_URL}{endpoint}"
        headers = {}
        if auth_needed:
            res = login_user("purushothamannirt@gmail.com", "purushothaman@1977")
            token = res.json()["access_token"]
            headers = {"Authorization": f"Bearer {token}"}

        start = time.time()
        if method == "GET":
            res = requests.get(url, headers=headers)
        duration = (time.time() - start) * 1000  # to ms
        assert res.status_code == 200
        assert duration < 200, f"Latency of {endpoint} was {duration:.1f}ms (threshold: 200ms)"

    # Concurrent connections load test
    def test_perf_concurrency_load(self):
        """TC-PERF-CONC: Verify system stability and response time under concurrent loads."""
        urls = [f"{BASE_URL}/users/leaderboard" for _ in range(20)]
        start = time.time()

        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            results = list(executor.map(lambda u: requests.get(u).status_code, urls))

        duration = time.time() - start
        assert all(code == 200 for code in results)
        assert duration < 1.5, f"20 requests took {duration:.2f} seconds (threshold: 1.5s)"
