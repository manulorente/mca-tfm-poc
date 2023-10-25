from fastapi import FastAPI

from ...main import app


def test_create_application():
	assert isinstance(app, FastAPI)
