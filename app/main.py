from fastapi import FastAPI

from .routers import users
from .internal.logger import logger_config
from .internal.config import get_settings

logger = logger_config(__name__)
settings = get_settings()

app = FastAPI(
    title=settings.APP_NAME,
    description=settings.DESCRIPTION,
    version=settings.VERSION,
    docs_url=settings.DOC_URL,
    debug=settings.ENV,
)

app.include_router(users.router, prefix="/api/v1")

logger.info("Application created")
