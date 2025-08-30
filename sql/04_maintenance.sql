-- =====================================================
-- Database Maintenance Scripts
-- OpenV0 Database Maintenance and Optimization
-- =====================================================

-- =====================================================
-- Cleanup Functions
-- =====================================================

-- Function to cleanup old data (run daily)
CREATE OR REPLACE FUNCTION perform_daily_cleanup()
RETURNS JSON AS $$
DECLARE
    sessions_deleted INTEGER;
    previews_deleted INTEGER;
    result JSON;
BEGIN
    -- Cleanup old generation sessions (older than 7 days)
    DELETE FROM generation_sessions 
    WHERE started_at < NOW() - INTERVAL '7 days'
    AND status IN ('completed', 'failed');
    
    GET DIAGNOSTICS sessions_deleted = ROW_COUNT;
    
    -- Cleanup old preview states (older than 3 days)
    DELETE FROM preview_states 
    WHERE updated_at < NOW() - INTERVAL '3 days'
    AND is_active = false;
    
    GET DIAGNOSTICS previews_deleted = ROW_COUNT;
    
    -- Return cleanup results
    result = json_build_object(
        'sessions_deleted', sessions_deleted,
        'previews_deleted', previews_deleted,
        'cleanup_timestamp', NOW()
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to cleanup abandoned projects (run weekly)
CREATE OR REPLACE FUNCTION cleanup_abandoned_projects()
RETURNS INTEGER AS $$
DECLARE
    projects_deleted INTEGER;
BEGIN
    -- Delete projects that have been pending for more than 30 days
    -- and have no associated sessions
    DELETE FROM projects 
    WHERE status = 'pending'
    AND created_at < NOW() - INTERVAL '30 days'
    AND NOT EXISTS (
        SELECT 1 FROM generation_sessions 
        WHERE generation_sessions.project_id = projects.id
    );
    
    GET DIAGNOSTICS projects_deleted = ROW_COUNT;
    RETURN projects_deleted;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Performance Optimization
-- =====================================================

-- Function to analyze and update table statistics
CREATE OR REPLACE FUNCTION update_table_statistics()
RETURNS VOID AS $$
BEGIN
    -- Update statistics for all tables
    ANALYZE projects;
    ANALYZE generation_sessions;
    ANALYZE preview_states;
    
    -- Log the operation
    RAISE NOTICE 'Table statistics updated at %', NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check index usage and performance
CREATE OR REPLACE FUNCTION check_index_performance()
RETURNS TABLE (
    table_name TEXT,
    index_name TEXT,
    index_size TEXT,
    index_scans BIGINT,
    index_tuples_read BIGINT,
    index_tuples_fetched BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        schemaname::TEXT,
        indexname::TEXT,
        pg_size_pretty(pg_relation_size(indexrelid))::TEXT,
        idx_scan,
        idx_tup_read,
        idx_tup_fetch
    FROM pg_stat_user_indexes 
    WHERE schemaname = 'public'
    ORDER BY idx_scan DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Monitoring and Health Checks
-- =====================================================

-- Function to get database health metrics
CREATE OR REPLACE FUNCTION get_database_health()
RETURNS JSON AS $$
DECLARE
    total_projects INTEGER;
    total_sessions INTEGER;
    total_previews INTEGER;
    active_sessions INTEGER;
    recent_activity INTEGER;
    result JSON;
BEGIN
    -- Get basic counts
    SELECT COUNT(*) INTO total_projects FROM projects;
    SELECT COUNT(*) INTO total_sessions FROM generation_sessions;
    SELECT COUNT(*) INTO total_previews FROM preview_states;
    
    -- Get active sessions (last 24 hours)
    SELECT COUNT(*) INTO active_sessions 
    FROM generation_sessions 
    WHERE started_at > NOW() - INTERVAL '24 hours';
    
    -- Get recent activity (last hour)
    SELECT COUNT(*) INTO recent_activity 
    FROM generation_sessions 
    WHERE started_at > NOW() - INTERVAL '1 hour';
    
    -- Build result object
    result = json_build_object(
        'total_projects', total_projects,
        'total_sessions', total_sessions,
        'total_previews', total_previews,
        'active_sessions_24h', active_sessions,
        'recent_activity_1h', recent_activity,
        'database_size', pg_size_pretty(pg_database_size(current_database())),
        'last_vacuum', (SELECT last_vacuum FROM pg_stat_user_tables WHERE tablename = 'projects'),
        'health_check_timestamp', NOW()
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check for potential issues
CREATE OR REPLACE FUNCTION check_database_issues()
RETURNS TABLE (
    issue_type TEXT,
    description TEXT,
    severity TEXT,
    recommendation TEXT
) AS $$
BEGIN
    -- Check for long-running sessions
    RETURN QUERY
    SELECT 
        'Long Running Session'::TEXT,
        'Session ' || id || ' has been running for more than 2 hours'::TEXT,
        'WARNING'::TEXT,
        'Consider investigating stuck sessions'::TEXT
    FROM generation_sessions 
    WHERE status = 'in_progress' 
    AND started_at < NOW() - INTERVAL '2 hours';
    
    -- Check for large preview states
    RETURN QUERY
    SELECT 
        'Large Preview State'::TEXT,
        'Preview state ' || id || ' is larger than 1MB'::TEXT,
        'INFO'::TEXT,
        'Consider optimizing preview content'::TEXT
    FROM preview_states 
    WHERE octet_length(html_content) + octet_length(css_content) + octet_length(js_content) > 1048576;
    
    -- Check for orphaned preview states
    RETURN QUERY
    SELECT 
        'Orphaned Preview State'::TEXT,
        'Preview state ' || ps.id || ' has no active session'::TEXT,
        'WARNING'::TEXT,
        'Consider cleaning up orphaned preview states'::TEXT
    FROM preview_states ps
    LEFT JOIN generation_sessions gs ON ps.session_id = gs.id
    WHERE gs.id IS NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Backup and Recovery
-- =====================================================

-- Function to create backup metadata
CREATE OR REPLACE FUNCTION create_backup_metadata()
RETURNS JSON AS $$
DECLARE
    backup_info JSON;
BEGIN
    backup_info = json_build_object(
        'backup_timestamp', NOW(),
        'database_name', current_database(),
        'database_size', pg_size_pretty(pg_database_size(current_database())),
        'table_count', (
            SELECT COUNT(*) 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        ),
        'total_rows', (
            SELECT SUM(reltuples)::BIGINT 
            FROM pg_class 
            WHERE relkind = 'r' 
            AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
        ),
        'version', version()
    );
    
    RETURN backup_info;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Scheduled Maintenance Jobs
-- =====================================================

-- Function to run all maintenance tasks
CREATE OR REPLACE FUNCTION run_maintenance_tasks()
RETURNS JSON AS $$
DECLARE
    cleanup_result JSON;
    projects_deleted INTEGER;
    maintenance_result JSON;
BEGIN
    -- Run daily cleanup
    SELECT perform_daily_cleanup() INTO cleanup_result;
    
    -- Cleanup abandoned projects
    SELECT cleanup_abandoned_projects() INTO projects_deleted;
    
    -- Update statistics
    PERFORM update_table_statistics();
    
    -- Build maintenance report
    maintenance_result = json_build_object(
        'cleanup_result', cleanup_result,
        'abandoned_projects_deleted', projects_deleted,
        'statistics_updated', true,
        'maintenance_timestamp', NOW()
    );
    
    RETURN maintenance_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- Comments for Documentation
-- =====================================================

COMMENT ON FUNCTION perform_daily_cleanup() IS 'Performs daily cleanup of old sessions and preview states';
COMMENT ON FUNCTION cleanup_abandoned_projects() IS 'Removes abandoned projects that have been pending for 30+ days';
COMMENT ON FUNCTION update_table_statistics() IS 'Updates table statistics for query optimization';
COMMENT ON FUNCTION check_index_performance() IS 'Returns index usage statistics for performance monitoring';
COMMENT ON FUNCTION get_database_health() IS 'Returns comprehensive database health metrics';
COMMENT ON FUNCTION check_database_issues() IS 'Identifies potential database issues and provides recommendations';
COMMENT ON FUNCTION create_backup_metadata() IS 'Creates metadata for database backup operations';
COMMENT ON FUNCTION run_maintenance_tasks() IS 'Runs all maintenance tasks and returns comprehensive report';

-- =====================================================
-- Usage Instructions
-- =====================================================

/*
MAINTENANCE SCHEDULE:

Daily Tasks (run automatically):
- perform_daily_cleanup()

Weekly Tasks (run manually):
- cleanup_abandoned_projects()
- update_table_statistics()
- check_database_issues()

Monthly Tasks (run manually):
- check_index_performance()
- get_database_health()

USAGE EXAMPLES:

-- Run daily cleanup
SELECT perform_daily_cleanup();

-- Check database health
SELECT get_database_health();

-- Run all maintenance tasks
SELECT run_maintenance_tasks();

-- Check for issues
SELECT * FROM check_database_issues();

-- Monitor index performance
SELECT * FROM check_index_performance();

AUTOMATION:

For production, set up cron jobs or use pg_cron extension:

-- Daily cleanup at 2 AM
SELECT cron.schedule('daily-cleanup', '0 2 * * *', 'SELECT perform_daily_cleanup();');

-- Weekly maintenance on Sundays at 3 AM
SELECT cron.schedule('weekly-maintenance', '0 3 * * 0', 'SELECT run_maintenance_tasks();');
*/
