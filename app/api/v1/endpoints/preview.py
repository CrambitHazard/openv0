"""
Preview API endpoints for OpenV0.
"""

from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, Any
import structlog

from app.services.preview_service import PreviewService
from app.core.logging import get_logger

router = APIRouter()
logger = get_logger(__name__)


@router.post("/update")
async def update_preview(
    preview_data: Dict[str, Any],
    preview_service: PreviewService = Depends()
) -> Dict[str, Any]:
    """Update the live preview with new code."""
    try:
        result = await preview_service.update_preview(preview_data)
        logger.info("Updated preview", session_id=preview_data.get("session_id"))
        return result
    except Exception as e:
        logger.error("Failed to update preview", error=str(e))
        raise HTTPException(status_code=500, detail="Failed to update preview")


@router.get("/{session_id}")
async def get_preview(
    session_id: str,
    preview_service: PreviewService = Depends()
) -> Dict[str, Any]:
    """Get the current preview state for a session."""
    try:
        preview = await preview_service.get_preview(session_id)
        if not preview:
            raise HTTPException(status_code=404, detail="Preview not found")
        return preview
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to get preview", session_id=session_id, error=str(e))
        raise HTTPException(status_code=500, detail="Failed to get preview")


@router.post("/refresh/{session_id}")
async def refresh_preview(
    session_id: str,
    preview_service: PreviewService = Depends()
) -> Dict[str, Any]:
    """Refresh the preview for a session."""
    try:
        result = await preview_service.refresh_preview(session_id)
        logger.info("Refreshed preview", session_id=session_id)
        return result
    except Exception as e:
        logger.error("Failed to refresh preview", session_id=session_id, error=str(e))
        raise HTTPException(status_code=500, detail="Failed to refresh preview")
