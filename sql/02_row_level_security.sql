-- =====================================================
-- Row Level Security (RLS) Policies
-- OpenV0 Database Security Implementation
-- =====================================================

-- Enable Row Level Security on all tables
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE generation_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE preview_states ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Projects RLS Policies
-- =====================================================

-- Policy: Allow read access to all projects (for MVP - no authentication)
-- In production, this would be restricted to authenticated users
CREATE POLICY "Allow read access to projects" ON projects
    FOR SELECT USING (true);

-- Policy: Allow insert for new projects
CREATE POLICY "Allow insert projects" ON projects
    FOR INSERT WITH CHECK (true);

-- Policy: Allow update for project owners (by session/API key for MVP)
CREATE POLICY "Allow update projects" ON projects
    FOR UPDATE USING (true);

-- Policy: Allow delete for project owners
CREATE POLICY "Allow delete projects" ON projects
    FOR DELETE USING (true);

-- =====================================================
-- Generation Sessions RLS Policies
-- =====================================================

-- Policy: Allow read access to sessions for their associated projects
CREATE POLICY "Allow read generation sessions" ON generation_sessions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM projects 
            WHERE projects.id = generation_sessions.project_id
        )
    );

-- Policy: Allow insert for new sessions
CREATE POLICY "Allow insert generation sessions" ON generation_sessions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM projects 
            WHERE projects.id = generation_sessions.project_id
        )
    );

-- Policy: Allow update for session progress and status
CREATE POLICY "Allow update generation sessions" ON generation_sessions
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM projects 
            WHERE projects.id = generation_sessions.project_id
        )
    );

-- Policy: Allow delete for session cleanup
CREATE POLICY "Allow delete generation sessions" ON generation_sessions
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM projects 
            WHERE projects.id = generation_sessions.project_id
        )
    );

-- =====================================================
-- Preview States RLS Policies
-- =====================================================

-- Policy: Allow read access to preview states for their sessions
CREATE POLICY "Allow read preview states" ON preview_states
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM generation_sessions 
            WHERE generation_sessions.id = preview_states.session_id
        )
    );

-- Policy: Allow insert for new preview states
CREATE POLICY "Allow insert preview states" ON preview_states
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM generation_sessions 
            WHERE generation_sessions.id = preview_states.session_id
        )
    );

-- Policy: Allow update for preview content updates
CREATE POLICY "Allow update preview states" ON preview_states
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM generation_sessions 
            WHERE generation_sessions.id = preview_states.session_id
        )
    );

-- Policy: Allow delete for preview cleanup
CREATE POLICY "Allow delete preview states" ON preview_states
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM generation_sessions 
            WHERE generation_sessions.id = preview_states.session_id
        )
    );

-- =====================================================
-- Session Isolation Functions
-- =====================================================

-- Function to get session ID from current context
-- This would be set by the application layer
CREATE OR REPLACE FUNCTION get_current_session_id()
RETURNS UUID AS $$
BEGIN
    -- For MVP, return NULL to allow all access
    -- In production, this would return the session ID from application context
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user has access to a project
CREATE OR REPLACE FUNCTION has_project_access(project_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- For MVP, allow all access
    -- In production, this would check user permissions
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Data Cleanup Functions
-- =====================================================

-- Function to cleanup old sessions (older than 24 hours)
CREATE OR REPLACE FUNCTION cleanup_old_sessions()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM generation_sessions 
    WHERE started_at < NOW() - INTERVAL '24 hours'
    AND status IN ('completed', 'failed');
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to cleanup old preview states
CREATE OR REPLACE FUNCTION cleanup_old_previews()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM preview_states 
    WHERE updated_at < NOW() - INTERVAL '12 hours'
    AND is_active = false;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Audit Trail Functions (Optional for MVP)
-- =====================================================

-- Function to log data access (for future audit trails)
CREATE OR REPLACE FUNCTION log_data_access(
    table_name TEXT,
    operation TEXT,
    record_id UUID,
    session_id UUID DEFAULT NULL
)
RETURNS VOID AS $$
BEGIN
    -- For MVP, this is a no-op
    -- In production, this would log to an audit table
    NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Comments for Documentation
-- =====================================================

COMMENT ON FUNCTION get_current_session_id() IS 'Returns the current session ID for RLS policies (MVP: allows all access)';
COMMENT ON FUNCTION has_project_access(UUID) IS 'Checks if current user has access to a project (MVP: allows all access)';
COMMENT ON FUNCTION cleanup_old_sessions() IS 'Removes old generation sessions to prevent database bloat';
COMMENT ON FUNCTION cleanup_old_previews() IS 'Removes old preview states to prevent database bloat';
COMMENT ON FUNCTION log_data_access(TEXT, TEXT, UUID, UUID) IS 'Logs data access for audit trails (MVP: no-op)';

-- =====================================================
-- Security Notes
-- =====================================================

/*
SECURITY CONSIDERATIONS FOR MVP:

1. RLS is enabled but policies are permissive for MVP
2. No authentication system implemented
3. Session isolation is handled at application level
4. Data cleanup functions prevent database bloat
5. Audit logging is prepared but disabled for MVP

PRODUCTION SECURITY UPGRADES:

1. Implement proper authentication and user management
2. Restrict RLS policies to authenticated users only
3. Add session-based access control
4. Enable audit logging
5. Implement API key validation and rate limiting
6. Add data encryption for sensitive fields
*/
