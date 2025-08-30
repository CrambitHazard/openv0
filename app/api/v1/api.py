"""
Main API router for OpenV0 application.
"""

from fastapi import APIRouter

from app.api.v1.endpoints import projects, generation, preview

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(projects.router, prefix="/projects", tags=["projects"])
api_router.include_router(generation.router, prefix="/generation", tags=["generation"])
api_router.include_router(preview.router, prefix="/preview", tags=["preview"])
