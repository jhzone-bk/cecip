from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .core.config import settings
from .core.database import engine, Base
from .api import articles, brands, vehicles, admin, ai_config

app = FastAPI(title=settings.app_name, version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)

@app.get("/health")
async def health():
    return {"status": "ok", "app": settings.app_name}

app.include_router(articles.router, prefix="/api/v1/articles", tags=["Articles"])
app.include_router(brands.router, prefix="/api/v1/brands", tags=["Brands"])
app.include_router(vehicles.router, prefix="/api/v1/vehicles", tags=["Vehicles"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])
app.include_router(ai_config.router, prefix="/api/v1/admin/ai", tags=["AI Config"])
