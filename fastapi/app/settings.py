from typing import List, Union

from pydantic import AnyHttpUrl, PostgresDsn
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings."""

    # App configuration
    APP_ENV: str = "development"
    DEBUG: bool = True
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # Database - allow string for test mode (SQLite)
    DATABASE_URL: Union[PostgresDsn, str]

    # CORS
    CORS_ORIGINS: List[AnyHttpUrl] = []

    # Logging
    LOG_LEVEL: str = "INFO"

    model_config = SettingsConfigDict(
        env_file=(".env", ".env.local"), case_sensitive=True, extra="ignore"
    )


settings = Settings()  # type: ignore[call-arg]
