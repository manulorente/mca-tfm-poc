from fastapi import FastAPI

from app.main import app

def test_create_application():
    assert isinstance(app, FastAPI)