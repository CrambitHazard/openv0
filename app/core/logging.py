"""
Logging configuration for the OpenV0 application.
"""

import sys
import structlog
from typing import Any, Dict


def setup_logging() -> None:
    """Setup structured logging configuration."""
    
    # Configure structlog
    structlog.configure(
        processors=[
            structlog.stdlib.filter_by_level,
            structlog.stdlib.add_logger_name,
            structlog.stdlib.add_log_level,
            structlog.stdlib.PositionalArgumentsFormatter(),
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.StackInfoRenderer(),
            structlog.processors.format_exc_info,
            structlog.processors.UnicodeDecoder(),
            structlog.processors.JSONRenderer()
        ],
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        wrapper_class=structlog.stdlib.BoundLogger,
        cache_logger_on_first_use=True,
    )
    
    # Configure standard library logging
    import logging
    
    logging.basicConfig(
        format="%(message)s",
        stream=sys.stdout,
        level=logging.INFO,
    )


def get_logger(name: str) -> structlog.BoundLogger:
    """Get a structured logger instance."""
    return structlog.get_logger(name)


def log_request(request_data: Dict[str, Any], logger: structlog.BoundLogger) -> None:
    """Log incoming request data."""
    logger.info(
        "Incoming request",
        method=request_data.get("method"),
        path=request_data.get("path"),
        user_agent=request_data.get("user_agent"),
        ip=request_data.get("ip"),
    )


def log_response(response_data: Dict[str, Any], logger: structlog.BoundLogger) -> None:
    """Log outgoing response data."""
    logger.info(
        "Outgoing response",
        status_code=response_data.get("status_code"),
        response_time=response_data.get("response_time"),
        path=response_data.get("path"),
    )


def log_error(error: Exception, logger: structlog.BoundLogger, context: Dict[str, Any] = None) -> None:
    """Log error with context."""
    error_context = context or {}
    error_context.update({
        "error_type": type(error).__name__,
        "error_message": str(error),
    })
    
    logger.error("Application error", **error_context)
