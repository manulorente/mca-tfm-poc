import pytest
from httpx import AsyncClient

from app.main import app

@pytest.mark.asyncio
async def test_get_users():
    async with AsyncClient(app =  app, 
                           base_url="http://localhost") as client:
        response = await client.get("/api/v1/users")
        assert response.status_code == 200
        assert response.headers["content-type"] == "application/json"
        assert response.json() == [{"username": "johndoe"}, 
                                   {"username": "janedoe"}]

@pytest.mark.asyncio
async def test_get_user():
    async with AsyncClient(app = app, 
                           base_url="http://localhost") as client:
        response = await client.get("/api/v1/users/johndoe")
        assert response.status_code == 200
        assert response.headers["content-type"] == "application/json"
        assert response.json() == {"username": "johndoe"}
