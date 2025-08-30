# API Structure: OpenV0 AI-Powered Web App Generator

## 🎯 **API Overview**

The OpenV0 API is designed as a RESTful service with WebSocket support for real-time communication. It follows OpenAPI 3.0 specifications and provides comprehensive endpoints for project management, AI-powered generation, and live preview functionality.

## 🌐 **Base Configuration**

```
Base URL: http://localhost:8000/api/v1
Content-Type: application/json
Authentication: API Key (OpenRouter) - Client-side storage for MVP
```

## 📋 **API Endpoints**

### **1. Projects API**

#### **GET /api/v1/projects**
List all projects with pagination support.

**Query Parameters:**
- `skip` (integer, optional): Number of records to skip (default: 0)
- `limit` (integer, optional): Maximum number of records to return (default: 100)
- `status` (string, optional): Filter by project status

**Response:**
```json
{
  "projects": [
    {
      "id": "uuid",
      "name": "My Portfolio Website",
      "description": "A modern portfolio website",
      "prompt": "Create a portfolio website with dark theme...",
      "status": "completed",
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T11:45:00Z"
    }
  ],
  "total": 25,
  "skip": 0,
  "limit": 100
}
```

#### **POST /api/v1/projects**
Create a new project.

**Request Body:**
```json
{
  "name": "My Portfolio Website",
  "description": "A modern portfolio website with dark theme",
  "prompt": "Create a portfolio website with dark theme, modern animations, and responsive design. Include sections for about, projects, skills, and contact."
}
```

**Response:**
```json
{
  "id": "uuid",
  "name": "My Portfolio Website",
  "description": "A modern portfolio website with dark theme",
  "prompt": "Create a portfolio website with dark theme...",
  "status": "pending",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

#### **GET /api/v1/projects/{project_id}**
Get a specific project by ID.

**Response:**
```json
{
  "id": "uuid",
  "name": "My Portfolio Website",
  "description": "A modern portfolio website with dark theme",
  "prompt": "Create a portfolio website with dark theme...",
  "status": "completed",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T11:45:00Z",
  "sessions": [
    {
      "id": "session-uuid",
      "status": "completed",
      "started_at": "2024-01-15T10:30:00Z",
      "completed_at": "2024-01-15T11:45:00Z"
    }
  ]
}
```

#### **PUT /api/v1/projects/{project_id}**
Update an existing project.

**Request Body:**
```json
{
  "name": "Updated Portfolio Website",
  "description": "Updated description",
  "prompt": "Updated prompt..."
}
```

#### **DELETE /api/v1/projects/{project_id}**
Delete a project and all associated data.

**Response:**
```json
{
  "message": "Project deleted successfully"
}
```

### **2. Generation API**

#### **POST /api/v1/generation/plan**
Generate a development plan for website creation.

**Request Body:**
```json
{
  "prompt": "Create a portfolio website with dark theme, modern animations, and responsive design. Include sections for about, projects, skills, and contact.",
  "api_key": "openrouter-api-key",
  "preferences": {
    "framework": "react",
    "style": "modern",
    "features": ["responsive", "animations", "dark-theme"]
  }
}
```

**Response:**
```json
{
  "plan_id": "plan-uuid",
  "steps": [
    {
      "id": "step_1",
      "type": "setup",
      "title": "Project Setup",
      "description": "Initialize React project with Vite and configure Tailwind CSS",
      "dependencies": [],
      "estimated_time": 30,
      "order": 1
    },
    {
      "id": "step_2",
      "type": "layout",
      "title": "Layout Structure",
      "description": "Create main layout components and navigation",
      "dependencies": ["step_1"],
      "estimated_time": 45,
      "order": 2
    },
    {
      "id": "step_3",
      "type": "components",
      "title": "Section Components",
      "description": "Build individual sections (About, Projects, Skills, Contact)",
      "dependencies": ["step_2"],
      "estimated_time": 120,
      "order": 3
    }
  ],
  "total_estimated_time": 195,
  "framework": "react",
  "features": ["responsive", "animations", "dark-theme"]
}
```

#### **POST /api/v1/generation/execute**
Execute the full website generation process.

**Request Body:**
```json
{
  "project_id": "project-uuid",
  "plan_id": "plan-uuid",
  "api_key": "openrouter-api-key"
}
```

**Response:**
```json
{
  "session_id": "session-uuid",
  "status": "started",
  "message": "Generation process started",
  "estimated_completion": "2024-01-15T11:45:00Z"
}
```

#### **POST /api/v1/generation/step**
Execute a single step of the generation process.

**Request Body:**
```json
{
  "session_id": "session-uuid",
  "step_id": "step_1",
  "api_key": "openrouter-api-key"
}
```

**Response:**
```json
{
  "step_id": "step_1",
  "status": "completed",
  "result": {
    "code": {
      "html": "<!DOCTYPE html>...",
      "css": "/* Tailwind CSS */...",
      "js": "// React components..."
    },
    "files": [
      {
        "path": "src/App.jsx",
        "content": "import React from 'react'..."
      }
    ]
  },
  "execution_time": 25
}
```

#### **GET /api/v1/generation/status/{session_id}**
Get the current status of a generation session.

**Response:**
```json
{
  "session_id": "session-uuid",
  "status": "in_progress",
  "current_step": "step_2",
  "completed_steps": ["step_1"],
  "total_steps": 3,
  "progress": 33,
  "started_at": "2024-01-15T10:30:00Z",
  "estimated_completion": "2024-01-15T11:45:00Z",
  "error": null
}
```

### **3. Preview API**

#### **POST /api/v1/preview/update**
Update the live preview with new code.

**Request Body:**
```json
{
  "session_id": "session-uuid",
  "html_content": "<!DOCTYPE html>...",
  "css_content": "/* Styles */...",
  "js_content": "// JavaScript...",
  "metadata": {
    "step_id": "step_2",
    "timestamp": "2024-01-15T10:35:00Z"
  }
}
```

**Response:**
```json
{
  "preview_id": "preview-uuid",
  "status": "updated",
  "url": "http://localhost:3000/preview/session-uuid",
  "timestamp": "2024-01-15T10:35:00Z"
}
```

#### **GET /api/v1/preview/{session_id}**
Get the current preview state for a session.

**Response:**
```json
{
  "session_id": "session-uuid",
  "html_content": "<!DOCTYPE html>...",
  "css_content": "/* Styles */...",
  "js_content": "// JavaScript...",
  "metadata": {
    "last_updated": "2024-01-15T10:35:00Z",
    "current_step": "step_2"
  },
  "url": "http://localhost:3000/preview/session-uuid"
}
```

#### **POST /api/v1/preview/refresh/{session_id}**
Refresh the preview for a session.

**Response:**
```json
{
  "status": "refreshed",
  "timestamp": "2024-01-15T10:40:00Z"
}
```

## 🔌 **WebSocket Events**

### **Connection**
```javascript
// Connect to WebSocket
const socket = io('http://localhost:8000', {
  query: {
    session_id: 'session-uuid'
  }
});
```

### **Event Types**

#### **generation:started**
Generation process has started.

```json
{
  "type": "generation:started",
  "data": {
    "session_id": "session-uuid",
    "project_id": "project-uuid",
    "total_steps": 3,
    "estimated_time": 195
  }
}
```

#### **generation:step**
Step execution update.

```json
{
  "type": "generation:step",
  "data": {
    "session_id": "session-uuid",
    "step_id": "step_2",
    "status": "in_progress",
    "progress": 50,
    "message": "Creating layout components..."
  }
}
```

#### **generation:completed**
Generation process completed.

```json
{
  "type": "generation:completed",
  "data": {
    "session_id": "session-uuid",
    "status": "completed",
    "total_time": 180,
    "files_generated": 15
  }
}
```

#### **generation:error**
Generation error occurred.

```json
{
  "type": "generation:error",
  "data": {
    "session_id": "session-uuid",
    "step_id": "step_2",
    "error": "API rate limit exceeded",
    "retry_available": true
  }
}
```

#### **preview:updated**
Preview content updated.

```json
{
  "type": "preview:updated",
  "data": {
    "session_id": "session-uuid",
    "step_id": "step_2",
    "url": "http://localhost:3000/preview/session-uuid",
    "timestamp": "2024-01-15T10:35:00Z"
  }
}
```

## 📊 **Data Models**

### **Project Model**
```typescript
interface Project {
  id: string;
  name: string;
  description?: string;
  prompt: string;
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  api_key_hash?: string;
  created_at: string;
  updated_at: string;
}
```

### **Generation Session Model**
```typescript
interface GenerationSession {
  id: string;
  project_id: string;
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  plan_data?: PlanData;
  execution_log?: ExecutionLog[];
  started_at: string;
  completed_at?: string;
  error_message?: string;
}
```

### **Plan Data Model**
```typescript
interface PlanData {
  steps: PlanStep[];
  total_estimated_time: number;
  framework: string;
  features: string[];
}

interface PlanStep {
  id: string;
  type: 'setup' | 'layout' | 'components' | 'styling' | 'functionality';
  title: string;
  description: string;
  dependencies: string[];
  estimated_time: number;
  order: number;
}
```

### **Preview State Model**
```typescript
interface PreviewState {
  id: string;
  session_id: string;
  html_content: string;
  css_content: string;
  js_content: string;
  metadata: Record<string, any>;
  created_at: string;
  updated_at: string;
}
```

## 🔐 **Authentication & Security**

### **API Key Validation**
- Client-side storage of OpenRouter API keys
- Server-side validation of API key format and validity
- Rate limiting per API key
- Secure transmission over HTTPS

### **Error Handling**
```json
{
  "error": {
    "code": "INVALID_API_KEY",
    "message": "Invalid or expired API key",
    "details": {
      "field": "api_key",
      "value": "invalid-key"
    }
  }
}
```

### **Rate Limiting**
- **Generation endpoints:** 10 requests per minute per API key
- **Preview endpoints:** 60 requests per minute per session
- **Project endpoints:** 100 requests per minute per session

## 🧪 **Testing**

### **API Testing Examples**

#### **Test Generation Plan**
```bash
curl -X POST "http://localhost:8000/api/v1/generation/plan" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Create a simple landing page",
    "api_key": "test-api-key",
    "preferences": {
      "framework": "react",
      "style": "modern"
    }
  }'
```

#### **Test WebSocket Connection**
```javascript
// Test WebSocket connection
const socket = io('http://localhost:8000');
socket.on('connect', () => {
  console.log('Connected to WebSocket');
});
socket.on('generation:started', (data) => {
  console.log('Generation started:', data);
});
```

## 📈 **Performance Considerations**

### **Response Times**
- **Simple queries:** < 100ms
- **Generation plan:** < 5 seconds
- **Step execution:** < 30 seconds
- **Full generation:** < 5 minutes

### **Caching Strategy**
- **Project data:** 5 minutes
- **Generation plans:** 1 hour
- **Preview content:** 10 minutes
- **API responses:** 2 minutes

### **Scalability**
- **Horizontal scaling:** Multiple API instances
- **Load balancing:** Round-robin distribution
- **Database connection pooling:** 20-50 connections per instance
- **WebSocket clustering:** Redis adapter for Socket.io

---

*This API structure provides a comprehensive foundation for the OpenV0 application with clear separation of concerns, real-time capabilities, and scalable design patterns.*
