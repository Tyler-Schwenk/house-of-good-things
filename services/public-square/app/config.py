"""
Configuration settings for Public Square API.

Loads environment variables and provides typed configuration objects.
"""

from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Database
    DATABASE_URL: str = "sqlite:///data/public_square.db"
    
    # JWT Authentication
    JWT_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION_MINUTES: int = 43200  # 30 days
    
    # CORS
    CORS_ORIGINS: str = ""
    
    # API Metadata
    API_TITLE: str = "Public Square API"
    API_VERSION: str = "1.0.0"
    API_DESCRIPTION: str = "Public forum API for posts, comments, and discussions"
    
    @property
    def cors_origins_list(self) -> List[str]:
        """Parse CORS origins from comma-separated string."""
        if not self.CORS_ORIGINS:
            return []
        return [origin.strip() for origin in self.CORS_ORIGINS.split(",")]
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Global settings instance
settings = Settings()
