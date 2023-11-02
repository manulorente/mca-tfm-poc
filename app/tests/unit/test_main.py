from fastapi import FastAPI

from api.main import app


def test_create_application():
	assert isinstance(app, FastAPI)
