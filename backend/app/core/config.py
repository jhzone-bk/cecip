from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    app_name: str = "CECIP"
    debug: bool = False
    
    # PostgreSQL
    db_host: str = "pgsql.serv00.com"
    db_port: int = 5432
    db_user: str = "p9756_cecip"
    db_password: str = "Mzone@123"
    db_name: str = "p9756_cecip"
    
    # AI API
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
