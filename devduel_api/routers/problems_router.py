import json
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from auth import get_current_user
from schemas import ProblemResponse, TestCaseSchema
import models

router = APIRouter(prefix="/problems", tags=["Problems"])


def _problem_to_response(p: models.Problem) -> ProblemResponse:
    starter_codes = json.loads(p.starter_codes) if p.starter_codes else {}
    raw_test_cases = json.loads(p.test_cases) if p.test_cases else []
    test_cases = [TestCaseSchema(**tc) for tc in raw_test_cases]
    return ProblemResponse(
        id=p.id,
        title=p.title,
        description=p.description,
        difficulty=p.difficulty,
        starterCodes=starter_codes,
        testCases=test_cases,
        points=p.points,
    )


@router.get("", response_model=list[ProblemResponse])
def list_problems(db: Session = Depends(get_db)):
    problems = db.query(models.Problem).all()
    return [_problem_to_response(p) for p in problems]


@router.get("/{problem_id}", response_model=ProblemResponse)
def get_problem(problem_id: str, db: Session = Depends(get_db)):
    p = db.query(models.Problem).filter(models.Problem.id == problem_id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Problem not found")
    return _problem_to_response(p)


@router.post("/seed", status_code=201)
def seed_problems(db: Session = Depends(get_db)):
    """Seed initial problems if the table is empty."""
    if db.query(models.Problem).count() > 0:
        return {"message": "Problems already seeded"}

    initial = [
        {
            "id": "1",
            "title": "Two Sum",
            "description": (
                "Given an array of integers nums and an integer target, "
                "return indices of the two numbers such that they add up to target."
            ),
            "difficulty": "easy",
            "starter_codes": json.dumps({
                "dart": "List<int> twoSum(List<int> nums, int target) {\n  // Write your code here\n}",
                "python": "def twoSum(nums, target):\n    # Write your code here\n    pass",
                "java": "class Solution {\n    public int[] twoSum(int[] nums, int target) {\n        // Write your code here\n    }\n}",
                "cpp": "class Solution {\npublic:\n    vector<int> twoSum(vector<int>& nums, int target) {\n        // Write your code here\n    }\n};",
                "c": "int* twoSum(int* nums, int numsSize, int target, int* returnSize) {\n    // Write your code here\n}",
            }),
            "test_cases": json.dumps([
                {"input": "[2,7,11,15], 9", "expectedOutput": "[0,1]"},
                {"input": "[3,2,4], 6", "expectedOutput": "[1,2]"},
            ]),
            "points": 50,
        },
        {
            "id": "2",
            "title": "Reverse String",
            "description": "Write a function that reverses a string.",
            "difficulty": "easy",
            "starter_codes": json.dumps({
                "dart": "String reverseString(String s) {\n  // Write your code here\n}",
                "python": "def reverseString(s):\n    # Write your code here\n    pass",
                "java": "class Solution {\n    public String reverseString(String s) {\n        // Write your code here\n    }\n}",
                "cpp": "class Solution {\npublic:\n    string reverseString(string s) {\n        // Write your code here\n    }\n};",
                "c": "char* reverseString(char* s) {\n    // Write your code here\n}",
            }),
            "test_cases": json.dumps([
                {"input": '"hello"', "expectedOutput": '"olleh"'},
                {"input": '"Hannah"', "expectedOutput": '"hannaH"'},
            ]),
            "points": 30,
        },
        {
            "id": "3",
            "title": "FizzBuzz",
            "description": (
                "Write a function that returns 'Fizz' for multiples of 3, "
                "'Buzz' for multiples of 5, 'FizzBuzz' for multiples of both, "
                "and the number as a string otherwise."
            ),
            "difficulty": "easy",
            "starter_codes": json.dumps({
                "dart": "String fizzBuzz(int n) {\n  // Write your code here\n}",
                "python": "def fizzBuzz(n):\n    # Write your code here\n    pass",
                "java": "class Solution {\n    public String fizzBuzz(int n) {\n        // Write your code here\n    }\n}",
                "cpp": "class Solution {\npublic:\n    string fizzBuzz(int n) {\n        // Write your code here\n    }\n};",
            }),
            "test_cases": json.dumps([
                {"input": "3", "expectedOutput": "Fizz"},
                {"input": "5", "expectedOutput": "Buzz"},
                {"input": "15", "expectedOutput": "FizzBuzz"},
                {"input": "7", "expectedOutput": "7"},
            ]),
            "points": 30,
        },
        {
            "id": "4",
            "title": "Palindrome Check",
            "description": "Given a string, determine if it is a palindrome, considering only alphanumeric characters.",
            "difficulty": "medium",
            "starter_codes": json.dumps({
                "dart": "bool isPalindrome(String s) {\n  // Write your code here\n}",
                "python": "def isPalindrome(s):\n    # Write your code here\n    pass",
                "java": "class Solution {\n    public boolean isPalindrome(String s) {\n        // Write your code here\n    }\n}",
                "cpp": "class Solution {\npublic:\n    bool isPalindrome(string s) {\n        // Write your code here\n    }\n};",
            }),
            "test_cases": json.dumps([
                {"input": '"racecar"', "expectedOutput": "true"},
                {"input": '"hello"', "expectedOutput": "false"},
            ]),
            "points": 75,
        },
        {
            "id": "5",
            "title": "Maximum Subarray",
            "description": (
                "Given an integer array nums, find the subarray with the largest sum, "
                "and return its sum. (Kadane's Algorithm)"
            ),
            "difficulty": "medium",
            "starter_codes": json.dumps({
                "dart": "int maxSubArray(List<int> nums) {\n  // Write your code here\n}",
                "python": "def maxSubArray(nums):\n    # Write your code here\n    pass",
                "java": "class Solution {\n    public int maxSubArray(int[] nums) {\n        // Write your code here\n    }\n}",
                "cpp": "class Solution {\npublic:\n    int maxSubArray(vector<int>& nums) {\n        // Write your code here\n    }\n};",
            }),
            "test_cases": json.dumps([
                {"input": "[-2,1,-3,4,-1,2,1,-5,4]", "expectedOutput": "6"},
                {"input": "[1]", "expectedOutput": "1"},
            ]),
            "points": 100,
        },
    ]

    for data in initial:
        db.add(models.Problem(**data))
    db.commit()
    return {"message": f"Seeded {len(initial)} problems successfully"}
