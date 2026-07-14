from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    # App
    app_name: str = "CECIP"
    debug: bool = False
    
    # MySQL
    db_host: str = "localhost"
    db_port: int = 3306
    db_user: str = "mzone"
    db_password: str = ""
    db_name: str = "cecip"
    
    # Redis (optional)
    redis_host: str = "localhost"
    redis_port: int = 6379
    
    # AI API - 支持中转地址
    ai_api_base: str = "https://api.openai.com/v1"
    ai_api_key: str = ""
    ai_model: str = "gpt-4o-mini"
    ai_fallback_api_base: str = ""
    ai_fallback_api_key: str = ""
    ai_fallback_model: str = ""
    
    # JWT
    jwt_secret: str = "cecip-secret-key-change-in-production"
    jwt_algorithm: str = "HS256"
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

settings = Settings()
