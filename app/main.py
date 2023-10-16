from fastapi import FastAPI

from .routers import users
from .internal.logger import logger_config
from .internal.config import get_settings

logger = logger_config(__name__)
settings = get_settings()

logger.info("Creating application...")

app = FastAPI(
    title=settings.APP_NAME,
    description=settings.DESCRIPTION,
    version=settings.VERSION,
    docs_url=settings.DOC_URL,
    debug=settings.ENV,
)

app.include_router(users.router, prefix=settings.PREFIX)

logger.info("Application created")
logger.info(f"Application name: {settings.APP_NAME}")
logger.info(f"Application version: {settings.VERSION}")
logger.info(f"Application environment: {settings.ENV}")
logger.info(f"Application prefix: {settings.PREFIX}")
logger.info(f"Application docs url: {settings.DOC_URL}")
logger.info(f"Application description: {settings.DESCRIPTION}")

