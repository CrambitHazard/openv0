"""
Projects API endpoints for OpenV0.
"""

from fastapi import APIRouter, HTTPException, Depends
from typing import List, Optional
import structlog

from app.models.project import Project, ProjectCreate, ProjectUpdate
from app.services.project_service import ProjectService
from app.core.logging import get_logger

router = APIRouter()
logger = get_logger(__name__)


@router.get("/", response_model=List[Project])
async def get_projects(
    skip: int = 0,
    limit: int = 100,
    project_service: ProjectService = Depends()
) -> List[Project]:
    """Get all projects."""
    try:
        projects = await project_service.get_projects(skip=skip, limit=limit)
        logger.info("Retrieved projects", count=len(projects))
        return projects
    except Exception as e:
        logger.error("Failed to retrieve projects", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to retrieve projects")


@router.get("/{project_id}", response_model=Project)
async def get_project(
    project_id: str,
    project_service: ProjectService = Depends()
) -> Project:
    """Get a specific project by ID."""
    try:
        project = await project_service.get_project(project_id)
        if not project:
            raise HTTPException(status_code=404, detail="Project not found")
        logger.info("Retrieved project", project_id=project_id)
        return project
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to retrieve project", project_id=project_id, error=str(e))
        raise HTTPException(status_code=500, detail="Failed to retrieve project")


@router.post("/", response_model=Project)
async def create_project(
    project: ProjectCreate,
    project_service: ProjectService = Depends()
) -> Project:
    """Create a new project."""
    try:
        created_project = await project_service.create_project(project)
        logger.info("Created project", project_id=created_project.id)
        return created_project
    except Exception as e:
        logger.error("Failed to create project", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to create project")


@router.put("/{project_id}", response_model=Project)
async def update_project(
    project_id: str,
    project_update: ProjectUpdate,
    project_service: ProjectService = Depends()
) -> Project:
    """Update an existing project."""
    try:
        updated_project = await project_service.update_project(project_id, project_update)
        if not updated_project:
            raise HTTPException(status_code=404, detail="Project not found")
        logger.info("Updated project", project_id=project_id)
        return updated_project
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to update project", project_id=project_id, error=str(e))
        raise HTTPException(status_code=500, detail="Failed to update project")


@router.delete("/{project_id}")
async def delete_project(
    project_id: str,
    project_service: ProjectService = Depends()
) -> dict:
    """Delete a project."""
    try:
        success = await project_service.delete_project(project_id)
        if not success:
            raise HTTPException(status_code=404, detail="Project not found")
        logger.info("Deleted project", project_id=project_id)
        return {"message": "Project deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to delete project", project_id=project_id, error=str(e))
        raise HTTPException(status_code=500, detail="Failed to delete project")
