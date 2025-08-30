# Real-time Communication System: OpenV0

## 🎯 **Overview**

The real-time communication system in OpenV0 enables live preview updates, progress tracking, and seamless user experience during the AI-powered website generation process. It uses WebSocket technology with Socket.io for reliable, bidirectional communication.

## 🏗️ **Architecture Overview**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   WebSocket     │    │   Backend       │
│   (React)       │◄──►│   Server        │◄──►│   Services      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   UI Updates    │    │   Event Bus     │    │   Generation    │
│   & State Mgmt  │    │   & Routing     │    │   Engine        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔌 **WebSocket Server Architecture**

### **Server Setup**
```python
# app/websocket/server.py
import socketio
from fastapi import FastAPI
from app.core.config import settings

# Create Socket.IO server
sio = socketio.AsyncServer(
    cors_allowed_origins=settings.ALLOWED_HOSTS,
    async_mode='asyncio',
    logger=True,
    engineio_logger=True
)

# Create Socket.IO app
socket_app = socketio.ASGIApp(sio)

# Mount to FastAPI
app.mount("/ws", socket_app)
```

### **Connection Management**
```python
@sio.event
async def connect(sid, environ, auth):
    """Handle client connection."""
    session_id = environ.get('HTTP_X_SESSION_ID')
    if session_id:
        await sio.save_session(sid, {'session_id': session_id})
        await sio.emit('connected', {'session_id': session_id}, room=sid)
    
    logger.info(f"Client connected: {sid}, Session: {session_id}")

@sio.event
async def disconnect(sid):
    """Handle client disconnection."""
    session = await sio.get_session(sid)
    session_id = session.get('session_id')
    
    # Cleanup session data
    await cleanup_session(session_id)
    logger.info(f"Client disconnected: {sid}, Session: {session_id}")
```

## 📡 **Event System**

### **Event Types**

#### **1. Generation Events**
```typescript
// Generation started
interface GenerationStartedEvent {
  type: 'generation:started';
  data: {
    session_id: string;
    project_id: string;
    total_steps: number;
    estimated_time: number;
    timestamp: string;
  };
}

// Step execution update
interface GenerationStepEvent {
  type: 'generation:step';
  data: {
    session_id: string;
    step_id: string;
    step_number: number;
    total_steps: number;
    status: 'pending' | 'in_progress' | 'completed' | 'failed';
    progress: number; // 0-100
    message: string;
    estimated_remaining: number;
    timestamp: string;
  };
}

// Generation completed
interface GenerationCompletedEvent {
  type: 'generation:completed';
  data: {
    session_id: string;
    status: 'completed' | 'failed';
    total_time: number;
    files_generated: number;
    final_url: string;
    timestamp: string;
  };
}

// Generation error
interface GenerationErrorEvent {
  type: 'generation:error';
  data: {
    session_id: string;
    step_id?: string;
    error_code: string;
    error_message: string;
    retry_available: boolean;
    timestamp: string;
  };
}
```

#### **2. Preview Events**
```typescript
// Preview updated
interface PreviewUpdatedEvent {
  type: 'preview:updated';
  data: {
    session_id: string;
    step_id: string;
    preview_url: string;
    html_content: string;
    css_content: string;
    js_content: string;
    metadata: Record<string, any>;
    timestamp: string;
  };
}

// Preview error
interface PreviewErrorEvent {
  type: 'preview:error';
  data: {
    session_id: string;
    error_code: string;
    error_message: string;
    timestamp: string;
  };
}
```

#### **3. System Events**
```typescript
// Connection events
interface ConnectedEvent {
  type: 'connected';
  data: {
    session_id: string;
    timestamp: string;
  };
}

// Heartbeat
interface HeartbeatEvent {
  type: 'heartbeat';
  data: {
    timestamp: string;
  };
}
```

## 🔄 **Event Flow**

### **1. Generation Process Flow**
```
1. User starts generation
   ↓
2. Backend creates session
   ↓
3. Emit 'generation:started'
   ↓
4. For each step:
   ├── Emit 'generation:step' (pending)
   ├── Execute step
   ├── Emit 'generation:step' (in_progress)
   ├── Emit 'preview:updated' (if code generated)
   └── Emit 'generation:step' (completed)
   ↓
5. Emit 'generation:completed'
```

### **2. Real-time Preview Flow**
```
1. Code generation completes
   ↓
2. Preview service processes code
   ↓
3. Update preview state in database
   ↓
4. Emit 'preview:updated' event
   ↓
5. Frontend receives event
   ↓
6. Update iframe content
   ↓
7. Trigger UI animations
```

## 🎯 **Frontend Integration**

### **WebSocket Client Setup**
```typescript
// hooks/useWebSocket.ts
import { useEffect, useRef, useState } from 'react';
import { io, Socket } from 'socket.io-client';

interface UseWebSocketOptions {
  sessionId: string;
  onGenerationStarted?: (data: GenerationStartedEvent['data']) => void;
  onGenerationStep?: (data: GenerationStepEvent['data']) => void;
  onGenerationCompleted?: (data: GenerationCompletedEvent['data']) => void;
  onPreviewUpdated?: (data: PreviewUpdatedEvent['data']) => void;
  onError?: (data: GenerationErrorEvent['data']) => void;
}

export function useWebSocket(options: UseWebSocketOptions) {
  const [isConnected, setIsConnected] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const socketRef = useRef<Socket | null>(null);

  useEffect(() => {
    // Initialize socket connection
    const socket = io('http://localhost:8000/ws', {
      query: { session_id: options.sessionId },
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 1000,
    });

    // Connection events
    socket.on('connect', () => {
      setIsConnected(true);
      setError(null);
    });

    socket.on('disconnect', () => {
      setIsConnected(false);
    });

    socket.on('connect_error', (err) => {
      setError(err.message);
    });

    // Generation events
    socket.on('generation:started', options.onGenerationStarted);
    socket.on('generation:step', options.onGenerationStep);
    socket.on('generation:completed', options.onGenerationCompleted);
    socket.on('generation:error', options.onError);

    // Preview events
    socket.on('preview:updated', options.onPreviewUpdated);
    socket.on('preview:error', options.onError);

    socketRef.current = socket;

    return () => {
      socket.disconnect();
    };
  }, [options.sessionId]);

  return {
    socket: socketRef.current,
    isConnected,
    error,
  };
}
```

### **Real-time Preview Component**
```typescript
// components/LivePreview.tsx
import { useEffect, useRef } from 'react';
import { useWebSocket } from '../hooks/useWebSocket';

interface LivePreviewProps {
  sessionId: string;
}

export function LivePreview({ sessionId }: LivePreviewProps) {
  const iframeRef = useRef<HTMLIFrameElement>(null);

  const { isConnected } = useWebSocket({
    sessionId,
    onPreviewUpdated: (data) => {
      updatePreview(data);
    },
    onError: (data) => {
      console.error('Preview error:', data);
    },
  });

  const updatePreview = (data: PreviewUpdatedEvent['data']) => {
    const iframe = iframeRef.current;
    if (!iframe || !iframe.contentDocument) return;

    // Update iframe content
    const html = `
      <!DOCTYPE html>
      <html>
        <head>
          <style>${data.css_content}</style>
        </head>
        <body>
          ${data.html_content}
          <script>${data.js_content}</script>
        </body>
      </html>
    `;

    iframe.contentDocument.open();
    iframe.contentDocument.write(html);
    iframe.contentDocument.close();
  };

  return (
    <div className="live-preview">
      <div className="preview-header">
        <h3>Live Preview</h3>
        <div className={`connection-status ${isConnected ? 'connected' : 'disconnected'}`}>
          {isConnected ? 'Connected' : 'Disconnected'}
        </div>
      </div>
      <iframe
        ref={iframeRef}
        className="preview-iframe"
        title="Live Preview"
        sandbox="allow-scripts allow-same-origin"
      />
    </div>
  );
}
```

### **Progress Tracking Component**
```typescript
// components/GenerationProgress.tsx
import { useState } from 'react';
import { useWebSocket } from '../hooks/useWebSocket';

interface GenerationProgressProps {
  sessionId: string;
}

export function GenerationProgress({ sessionId }: GenerationProgressProps) {
  const [progress, setProgress] = useState(0);
  const [currentStep, setCurrentStep] = useState<string>('');
  const [message, setMessage] = useState<string>('');

  const { isConnected } = useWebSocket({
    sessionId,
    onGenerationStarted: (data) => {
      setProgress(0);
      setMessage('Generation started...');
    },
    onGenerationStep: (data) => {
      setProgress(data.progress);
      setCurrentStep(data.step_id);
      setMessage(data.message);
    },
    onGenerationCompleted: (data) => {
      setProgress(100);
      setMessage('Generation completed!');
    },
    onError: (data) => {
      setMessage(`Error: ${data.error_message}`);
    },
  });

  return (
    <div className="generation-progress">
      <div className="progress-header">
        <h3>Generation Progress</h3>
        <div className={`connection-status ${isConnected ? 'connected' : 'disconnected'}`}>
          {isConnected ? 'Live' : 'Offline'}
        </div>
      </div>
      
      <div className="progress-bar">
        <div 
          className="progress-fill" 
          style={{ width: `${progress}%` }}
        />
      </div>
      
      <div className="progress-details">
        <div className="progress-percentage">{progress}%</div>
        <div className="current-step">{currentStep}</div>
        <div className="progress-message">{message}</div>
      </div>
    </div>
  );
}
```

## 🔧 **Backend Event Emission**

### **Event Service**
```python
# app/services/event_service.py
from typing import Dict, Any
import socketio
from app.core.logging import get_logger

logger = get_logger(__name__)

class EventService:
    def __init__(self, sio: socketio.AsyncServer):
        self.sio = sio
    
    async def emit_generation_started(self, session_id: str, data: Dict[str, Any]):
        """Emit generation started event."""
        event_data = {
            "session_id": session_id,
            "project_id": data.get("project_id"),
            "total_steps": data.get("total_steps"),
            "estimated_time": data.get("estimated_time"),
            "timestamp": data.get("timestamp")
        }
        
        await self.sio.emit('generation:started', event_data, room=session_id)
        logger.info(f"Emitted generation:started for session {session_id}")
    
    async def emit_generation_step(self, session_id: str, data: Dict[str, Any]):
        """Emit generation step event."""
        event_data = {
            "session_id": session_id,
            "step_id": data.get("step_id"),
            "step_number": data.get("step_number"),
            "total_steps": data.get("total_steps"),
            "status": data.get("status"),
            "progress": data.get("progress"),
            "message": data.get("message"),
            "estimated_remaining": data.get("estimated_remaining"),
            "timestamp": data.get("timestamp")
        }
        
        await self.sio.emit('generation:step', event_data, room=session_id)
        logger.info(f"Emitted generation:step for session {session_id}, step {data.get('step_id')}")
    
    async def emit_preview_updated(self, session_id: str, data: Dict[str, Any]):
        """Emit preview updated event."""
        event_data = {
            "session_id": session_id,
            "step_id": data.get("step_id"),
            "preview_url": data.get("preview_url"),
            "html_content": data.get("html_content"),
            "css_content": data.get("css_content"),
            "js_content": data.get("js_content"),
            "metadata": data.get("metadata"),
            "timestamp": data.get("timestamp")
        }
        
        await self.sio.emit('preview:updated', event_data, room=session_id)
        logger.info(f"Emitted preview:updated for session {session_id}")
    
    async def emit_error(self, session_id: str, error_data: Dict[str, Any]):
        """Emit error event."""
        event_data = {
            "session_id": session_id,
            "error_code": error_data.get("error_code"),
            "error_message": error_data.get("error_message"),
            "retry_available": error_data.get("retry_available", False),
            "timestamp": error_data.get("timestamp")
        }
        
        await self.sio.emit('generation:error', event_data, room=session_id)
        logger.error(f"Emitted error for session {session_id}: {error_data.get('error_message')}")
```

### **Integration with Generation Service**
```python
# app/services/generation_service.py
from app.services.event_service import EventService

class GenerationService:
    def __init__(self, event_service: EventService):
        self.event_service = event_service
    
    async def execute_generation(self, project_id: str, session_id: str):
        """Execute the full generation process with real-time updates."""
        try:
            # Emit generation started
            await self.event_service.emit_generation_started(session_id, {
                "project_id": project_id,
                "total_steps": 5,
                "estimated_time": 300,
                "timestamp": datetime.utcnow().isoformat()
            })
            
            # Execute steps with progress updates
            for i, step in enumerate(steps, 1):
                await self.event_service.emit_generation_step(session_id, {
                    "step_id": step.id,
                    "step_number": i,
                    "total_steps": len(steps),
                    "status": "in_progress",
                    "progress": (i / len(steps)) * 100,
                    "message": f"Executing {step.title}...",
                    "estimated_remaining": (len(steps) - i) * 60,
                    "timestamp": datetime.utcnow().isoformat()
                })
                
                # Execute step
                result = await self.execute_step(step)
                
                # Update preview if code generated
                if result.get("code"):
                    await self.event_service.emit_preview_updated(session_id, {
                        "step_id": step.id,
                        "preview_url": f"/preview/{session_id}",
                        "html_content": result["code"]["html"],
                        "css_content": result["code"]["css"],
                        "js_content": result["code"]["js"],
                        "metadata": {"step": step.id},
                        "timestamp": datetime.utcnow().isoformat()
                    })
                
                # Mark step as completed
                await self.event_service.emit_generation_step(session_id, {
                    "step_id": step.id,
                    "step_number": i,
                    "total_steps": len(steps),
                    "status": "completed",
                    "progress": (i / len(steps)) * 100,
                    "message": f"Completed {step.title}",
                    "estimated_remaining": (len(steps) - i) * 60,
                    "timestamp": datetime.utcnow().isoformat()
                })
            
            # Emit generation completed
            await self.event_service.emit_generation_completed(session_id, {
                "status": "completed",
                "total_time": 300,
                "files_generated": 15,
                "final_url": f"/preview/{session_id}",
                "timestamp": datetime.utcnow().isoformat()
            })
            
        except Exception as e:
            await self.event_service.emit_error(session_id, {
                "error_code": "GENERATION_FAILED",
                "error_message": str(e),
                "retry_available": True,
                "timestamp": datetime.utcnow().isoformat()
            })
```

## 🔒 **Security & Reliability**

### **Connection Security**
- **HTTPS/WSS:** All WebSocket connections use secure protocols
- **Origin Validation:** Server validates client origins
- **Session Isolation:** Each session is isolated in its own room
- **Rate Limiting:** Prevent abuse through connection limits

### **Reliability Features**
- **Automatic Reconnection:** Client automatically reconnects on disconnection
- **Message Queuing:** Offline messages are queued and delivered on reconnection
- **Heartbeat:** Regular heartbeat to detect connection issues
- **Error Recovery:** Graceful handling of connection errors

### **Performance Optimization**
- **Room-based Broadcasting:** Events only sent to relevant clients
- **Message Compression:** Large messages are compressed
- **Connection Pooling:** Efficient connection management
- **Memory Management:** Automatic cleanup of disconnected sessions

## 📊 **Monitoring & Debugging**

### **Connection Metrics**
```python
# Monitor connection statistics
@sio.event
async def get_stats(sid):
    """Get connection statistics."""
    stats = {
        "total_connections": len(sio.rooms),
        "active_sessions": len(sio.rooms),
        "memory_usage": get_memory_usage(),
        "uptime": get_uptime()
    }
    await sio.emit('stats', stats, room=sid)
```

### **Event Logging**
```python
# Log all events for debugging
@sio.event
async def log_event(sid, event_type, data):
    """Log event for debugging."""
    logger.info(f"Event: {event_type}, Session: {sid}, Data: {data}")
```

---

*This real-time communication system provides a robust foundation for live updates, progress tracking, and seamless user experience in the OpenV0 application.*
