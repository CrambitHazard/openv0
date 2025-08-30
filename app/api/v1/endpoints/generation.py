"""
Generation API endpoints for OpenV0.
"""

from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, Any
import structlog

from app.models.generation import GenerationRequest, GenerationResponse
from app.services.generation_service import GenerationService
from app.core.logging import get_logger

router = APIRouter()
logger = get_logger(__name__)


@router.post("/plan", response_model=Dict[str, Any])
async def generate_plan(
    request: GenerationRequest,
    generation_service: GenerationService = Depends()
) -> Dict[str, Any]:
    """Generate a development plan for the website."""
    try:
        plan = await generation_service.generate_plan(request.prompt)
        logger.info("Generated plan", prompt_length=len(request.prompt))
        return plan
    except Exception as e:
        logger.error("Failed to generate plan", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to generate plan")


@router.post("/execute", response_model=GenerationResponse)
async def execute_generation(
    request: GenerationRequest,
    generation_service: GenerationService = Depends()
) -> GenerationResponse:
    """Execute the full website generation process."""
    try:
        result = await generation_service.execute_generation(request.prompt)
        logger.info("Executed generation", prompt_length=len(request.prompt))
        return result
    except Exception as e:
        logger.error("Failed to execute generation", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to execute generation")


@router.post("/step", response_model=Dict[str, Any])
async def execute_step(
    step_data: Dict[str, Any],
    generation_service: GenerationService = Depends()
) -> Dict[str, Any]:
    """Execute a single step of the generation process."""
    try:
        result = await generation_service.execute_step(step_data)
        logger.info("Executed step", step_id=step_data.get("step_id"))
        return result
    except Exception as e:
        logger.error("Failed to execute step", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to execute step")


@router.get("/status/{session_id}")
async def get_generation_status(
    session_id: str,
    generation_service: GenerationService = Depends()
) -> Dict[str, Any]:
    """Get the status of a generation session."""
    try:
        status = await generation_service.get_status(session_id)
        if not status:
            raise HTTPException(status_code=404, detail="Session not found")
        return status
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to get status", session_id=session_id, error=str(e))
        raise HTTPException(status_code=500, detail="Failed to get status")
