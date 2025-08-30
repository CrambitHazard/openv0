-- =====================================================
-- OpenV0 Database Schema
-- Step 1.3: Database Design & Setup
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable full-text search
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =====================================================
-- Core Tables
-- =====================================================

-- Projects table - stores project metadata and configuration
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    prompt TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'failed')),
    api_key_hash VARCHAR(255), -- Stored locally for MVP
    framework VARCHAR(100), -- e.g., 'react', 'vue', 'vanilla'
    features JSONB DEFAULT '[]', -- Array of features like ['responsive', 'dark-theme']
    metadata JSONB DEFAULT '{}', -- Additional project metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Generation sessions table - tracks AI generation sessions
CREATE TABLE generation_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'failed')),
    plan_data JSONB, -- AI-generated development plan
    execution_log JSONB DEFAULT '[]', -- Array of execution steps and results
    current_step VARCHAR(100), -- Current step being executed
    progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    error_message TEXT,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    estimated_completion TIMESTAMP WITH TIME ZONE
);

-- Preview states table - stores live preview content
CREATE TABLE preview_states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES generation_sessions(id) ON DELETE CASCADE,
    html_content TEXT,
    css_content TEXT,
    js_content TEXT,
    metadata JSONB DEFAULT '{}', -- Preview metadata (step_id, timestamp, etc.)
    is_active BOOLEAN DEFAULT true, -- Only one active preview per session
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- Indexes for Performance
-- =====================================================

-- Projects indexes
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_created_at ON projects(created_at DESC);
CREATE INDEX idx_projects_framework ON projects(framework);
CREATE INDEX idx_projects_updated_at ON projects(updated_at DESC);

-- Full-text search on project descriptions and prompts
CREATE INDEX idx_projects_search ON projects USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '') || ' ' || prompt));

-- Generation sessions indexes
CREATE INDEX idx_generation_sessions_project_id ON generation_sessions(project_id);
CREATE INDEX idx_generation_sessions_status ON generation_sessions(status);
CREATE INDEX idx_generation_sessions_started_at ON generation_sessions(started_at DESC);
CREATE INDEX idx_generation_sessions_progress ON generation_sessions(progress);

-- Preview states indexes
CREATE INDEX idx_preview_states_session_id ON preview_states(session_id);
CREATE INDEX idx_preview_states_active ON preview_states(is_active) WHERE is_active = true;
CREATE INDEX idx_preview_states_updated_at ON preview_states(updated_at DESC);

-- =====================================================
-- Triggers for Automatic Timestamps
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables with updated_at columns
CREATE TRIGGER update_projects_updated_at 
    BEFORE UPDATE ON projects 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_preview_states_updated_at 
    BEFORE UPDATE ON preview_states 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- Comments for Documentation
-- =====================================================

COMMENT ON TABLE projects IS 'Stores project metadata and configuration for AI-powered website generation';
COMMENT ON TABLE generation_sessions IS 'Tracks AI generation sessions with progress and execution logs';
COMMENT ON TABLE preview_states IS 'Stores live preview content for real-time updates';

COMMENT ON COLUMN projects.framework IS 'The framework used for generation (react, vue, vanilla, etc.)';
COMMENT ON COLUMN projects.features IS 'JSON array of features like ["responsive", "dark-theme", "animations"]';
COMMENT ON COLUMN projects.metadata IS 'Additional project metadata in JSON format';

COMMENT ON COLUMN generation_sessions.plan_data IS 'AI-generated development plan with steps and dependencies';
COMMENT ON COLUMN generation_sessions.execution_log IS 'Array of execution steps with results and timestamps';
COMMENT ON COLUMN generation_sessions.progress IS 'Generation progress percentage (0-100)';

COMMENT ON COLUMN preview_states.html_content IS 'Generated HTML content for live preview';
COMMENT ON COLUMN preview_states.css_content IS 'Generated CSS content for live preview';
COMMENT ON COLUMN preview_states.js_content IS 'Generated JavaScript content for live preview';
COMMENT ON COLUMN preview_states.is_active IS 'Only one active preview per session (latest)';
