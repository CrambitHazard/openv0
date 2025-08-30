# System Architecture: OpenV0 AI-Powered Web App Generator

## 🎯 **Architecture Overview**

OpenV0 is designed as a modern, scalable, event-driven system that leverages AI to generate complete web applications from natural language descriptions. The architecture follows microservices principles with clear separation of concerns and real-time communication capabilities.

## 🏗️ **High-Level Architecture**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │   External      │
│   (Next.js)     │◄──►│   (FastAPI)     │◄──►│   Services      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Real-time     │    │   Database      │    │   AI/ML         │
│   Preview       │    │   (Supabase)    │    │   (OpenRouter)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 **Component Architecture**

### **1. Frontend Layer (Next.js 14)**
- **Technology Stack:** React 18, TypeScript, Tailwind CSS, shadcn/ui
- **Key Components:**
  - **API Key Management:** Secure input and validation
  - **Prompt Interface:** Rich text editor with suggestions
  - **Live Preview:** Real-time iframe with WebSocket updates
  - **Project Dashboard:** History and management interface
  - **Progress Tracking:** Real-time status indicators

### **2. Backend API Layer (FastAPI)**
- **Technology Stack:** Python 3.11+, FastAPI, Pydantic, SQLAlchemy
- **Key Services:**
  - **Project Service:** CRUD operations for projects
  - **Generation Service:** AI-powered code generation
  - **Preview Service:** Real-time preview management
  - **OpenRouter Service:** AI model integration
  - **WebSocket Service:** Real-time communication

### **3. Database Layer (Supabase)**
- **Technology Stack:** PostgreSQL, Row Level Security (RLS)
- **Key Tables:**
  - **projects:** Project metadata and configuration
  - **generation_sessions:** Session tracking and status
  - **api_keys:** User API key storage (local for MVP)
  - **preview_states:** Preview data and caching

### **4. External Services**
- **OpenRouter API:** DeepSeek model access
- **Supabase:** Database and real-time subscriptions
- **Redis (Optional):** Caching and session storage

## 🔄 **Data Flow Architecture**

### **1. Website Generation Flow**
```
User Input → Prompt Validation → AI Plan Generation → Step Execution → Live Preview
     │              │                    │                │              │
     ▼              ▼                    ▼                ▼              ▼
Frontend → Backend API → OpenRouter API → Code Gen → WebSocket → Preview Update
```

### **2. Real-time Communication Flow**
```
Backend Event → WebSocket Server → Frontend Client → UI Update
     │              │                    │              │
     ▼              ▼                    ▼              ▼
Code Change → Socket.io → React State → Component Re-render
```

## 🗄️ **Database Schema Design**

### **Core Tables**

#### **projects**
```sql
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    prompt TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    api_key_hash VARCHAR(255), -- Stored locally for MVP
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### **generation_sessions**
```sql
CREATE TABLE generation_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'pending',
    plan_data JSONB,
    execution_log JSONB,
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    error_message TEXT
);
```

#### **preview_states**
```sql
CREATE TABLE preview_states (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES generation_sessions(id) ON DELETE CASCADE,
    html_content TEXT,
    css_content TEXT,
    js_content TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Indexing Strategy**
- **Project status and created_at indexes** for efficient querying
- **Full-text search on project descriptions and prompts**
- **Session expiration indexes** for cleanup operations
- **Composite indexes** for common query patterns

## 🔐 **Security Architecture**

### **API Key Management (MVP)**
- **Storage:** Local browser storage (no server-side encryption for MVP)
- **Validation:** Client-side validation with server-side verification
- **Security:** HTTPS-only transmission, input sanitization
- **Cleanup:** Automatic cleanup of expired sessions

### **Data Protection**
- **Row Level Security (RLS)** policies on all tables
- **Input validation** and sanitization at all layers
- **Rate limiting** to prevent abuse
- **CORS configuration** for controlled access

### **Future Security Enhancements**
- **Encryption:** AES-256 encryption for sensitive data
- **Authentication:** JWT-based user authentication
- **Audit logging:** Comprehensive security event tracking
- **API key rotation:** Automatic key refresh mechanisms

## 🌐 **API Architecture**

### **RESTful Endpoints**

#### **Projects API**
```
GET    /api/v1/projects          # List projects
POST   /api/v1/projects          # Create project
GET    /api/v1/projects/{id}     # Get project
PUT    /api/v1/projects/{id}     # Update project
DELETE /api/v1/projects/{id}     # Delete project
```

#### **Generation API**
```
POST   /api/v1/generation/plan   # Generate development plan
POST   /api/v1/generation/execute # Execute full generation
POST   /api/v1/generation/step   # Execute single step
GET    /api/v1/generation/status/{session_id} # Get status
```

#### **Preview API**
```
POST   /api/v1/preview/update    # Update preview
GET    /api/v1/preview/{session_id} # Get preview state
POST   /api/v1/preview/refresh/{session_id} # Refresh preview
```

### **WebSocket Events**
```
generation:started     # Generation process started
generation:step        # Step execution update
generation:completed   # Generation completed
generation:error       # Generation error
preview:updated        # Preview content updated
preview:error          # Preview error
```

## ⚡ **Performance Architecture**

### **Caching Strategy**
- **Redis (Optional):** Session data and API response caching
- **Browser Caching:** Static assets and preview content
- **CDN:** Global content delivery for static resources
- **Database Query Caching:** Frequently accessed project data

### **Scalability Considerations**
- **Horizontal Scaling:** Stateless API design
- **Load Balancing:** Multiple API instances
- **Database Scaling:** Read replicas and connection pooling
- **Queue Management:** Background task processing

### **Monitoring & Observability**
- **Structured Logging:** JSON-formatted logs with correlation IDs
- **Metrics Collection:** Performance and business metrics
- **Error Tracking:** Comprehensive error reporting
- **Health Checks:** Service health monitoring

## 🔄 **Real-time Communication**

### **WebSocket Architecture**
```
Client ←→ WebSocket Server ←→ Event Bus ←→ Service Layer
   │              │              │              │
   ▼              ▼              ▼              ▼
UI Update    Connection Mgmt   Event Routing   Business Logic
```

### **Connection Management**
- **Simple session-based identification** (no authentication for MVP)
- **Automatic reconnection** with exponential backoff
- **Message queuing** for offline clients
- **Connection pooling** for efficient resource usage

### **Event Flow**
1. **Service Layer** generates events
2. **Event Bus** routes events to appropriate handlers
3. **WebSocket Server** broadcasts to connected clients
4. **Frontend** updates UI based on events

## 🧪 **Testing Architecture**

### **Test Pyramid**
- **Unit Tests:** 70% - Individual component testing
- **Integration Tests:** 20% - Service interaction testing
- **E2E Tests:** 10% - Full user workflow testing

### **Testing Strategy**
- **Frontend:** Jest, React Testing Library, Playwright
- **Backend:** pytest, FastAPI TestClient, async testing
- **Database:** Test containers, isolated test databases
- **API:** Contract testing, performance testing

## 🚀 **Deployment Architecture**

### **Environment Strategy**
- **Development:** Local development with hot reload
- **Staging:** Production-like environment for testing
- **Production:** Optimized, monitored, and secured

### **Container Strategy**
- **Frontend:** Next.js static export with CDN
- **Backend:** FastAPI with Gunicorn/Uvicorn
- **Database:** Managed Supabase instance
- **Caching:** Redis cluster (optional for MVP)

### **CI/CD Pipeline**
- **Build:** Automated dependency installation and testing
- **Test:** Comprehensive test suite execution
- **Deploy:** Automated deployment with rollback capability
- **Monitor:** Health checks and performance monitoring

## 📊 **Technology Stack Summary**

### **Frontend**
- **Framework:** Next.js 14 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS + shadcn/ui
- **State Management:** Redux Toolkit + React Query
- **Real-time:** Socket.io Client
- **Testing:** Jest + Playwright

### **Backend**
- **Framework:** FastAPI
- **Language:** Python 3.11+
- **Database:** Supabase (PostgreSQL)
- **ORM:** SQLAlchemy + Alembic
- **AI Integration:** OpenRouter API
- **Real-time:** Socket.io
- **Testing:** pytest + async testing

### **Infrastructure**
- **Database:** Supabase (managed PostgreSQL)
- **Caching:** Redis (optional for MVP)
- **CDN:** Vercel/Cloudflare
- **Monitoring:** Structured logging + metrics
- **Deployment:** Docker + CI/CD

## 🎯 **Architecture Principles**

### **1. Separation of Concerns**
- Clear boundaries between frontend, backend, and external services
- Modular design with well-defined interfaces
- Independent deployment and scaling of components

### **2. Event-Driven Design**
- Loose coupling through event-based communication
- Real-time updates without polling
- Scalable message handling

### **3. Security First**
- Defense in depth with multiple security layers
- Input validation at all entry points
- Secure handling of sensitive data

### **4. Performance Optimization**
- Caching at multiple levels
- Efficient database queries and indexing
- Optimized bundle sizes and loading

### **5. Developer Experience**
- Comprehensive testing and documentation
- Clear error handling and debugging
- Hot reload and development tools

## 🔮 **Future Architecture Considerations**

### **Scalability Enhancements**
- **Microservices:** Break down into smaller, focused services
- **Event Sourcing:** Complete audit trail of all changes
- **CQRS:** Separate read and write models
- **API Gateway:** Centralized API management

### **Advanced Features**
- **Multi-tenancy:** Support for multiple organizations
- **Plugin System:** Extensible architecture for custom features
- **AI Model Switching:** Support for multiple AI providers
- **Collaboration:** Real-time collaborative editing

---

*This architecture is designed to be flexible and can evolve as the application grows. Regular architecture reviews will ensure alignment with business goals and technical requirements.*
