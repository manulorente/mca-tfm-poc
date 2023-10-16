import pytest
from httpx import AsyncClient
from app.internal.config import get_settings

from app.main import app

settings = get_settings()

@pytest.mark.asyncio
async def test_get_users():
    async with AsyncClient(app =  app, 
                           base_url="http://localhost") as client:
        response = await client.get(f"{settings.PREFIX}/users")
        assert response.status_code == 200
        assert response.headers["content-type"] == "application/json"
        assert response.json() == [{"username": "johndoe"}, 
                                   {"username": "janedoe"}]

@pytest.mark.asyncio
async def test_get_user():
    async with AsyncClient(app = app, 
                           base_url="http://localhost") as client:
        response = await client.get(f"{settings.PREFIX}/users/johndoe")
        assert response.status_code == 200
        assert response.headers["content-type"] == "application/json"
        assert response.json() == {"username": "johndoe"}
