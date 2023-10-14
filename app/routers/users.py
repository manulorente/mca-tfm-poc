from fastapi import APIRouter
from httpx import Response

router = APIRouter()

@router.get("/users", tags=["users"])
async def get_users():
    return [{"username": "johndoe"}, {"username": "janedoe"}]

@router.get("/users/{username}", tags=["users"])
async def get_user(username: str):
    return {"username": username}
