-- CyberCare Database Schema
-- PostgreSQL Database Setup

-- Create database
-- CREATE DATABASE cybercare_db;

-- Use the database
-- \c cybercare_db;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password_hash TEXT NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    role VARCHAR(50) DEFAULT 'user' CHECK (role IN ('user', 'admin', 'cert_viewer')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_login TIMESTAMPTZ
);

-- Breach scan logs table
CREATE TABLE breach_scan_logs (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    breached_in TEXT[], -- Array of breach sources
    scanned_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) NOT NULL CHECK (status IN ('clean', 'breached'))
);

-- Threat reports table
CREATE TABLE threat_reports (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    links TEXT[], -- Array of URLs
    evidence TEXT, -- Base64 encoded image
    submitted_by VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Validated', 'False Alarm', 'Escalated')),
    submitted_at TIMESTAMPTZ DEFAULT NOW(),
    validated_at TIMESTAMPTZ,
    validated_by VARCHAR(255) REFERENCES users(id),
    remarks TEXT,
    virustotal_result JSONB -- Store VirusTotal scan results
);

-- Notifications table
CREATE TABLE notifications (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(100) NOT NULL CHECK (type IN ('breach_detected', 'report_status_change', 'general')),
    title VARCHAR(500) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'unseen' CHECK (status IN ('unseen', 'seen')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- Indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_breach_logs_user_id ON breach_scan_logs(user_id);
CREATE INDEX idx_breach_logs_status ON breach_scan_logs(status);
CREATE INDEX idx_threat_reports_submitted_by ON threat_reports(submitted_by);
CREATE INDEX idx_threat_reports_status ON threat_reports(status);
CREATE INDEX idx_threat_reports_submitted_at ON threat_reports(submitted_at);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_status ON notifications(status);
CREATE INDEX idx_notifications_type ON notifications(type);

-- Create sample admin user (password: admin123)
-- Note: Update the password hash according to your salt configuration
INSERT INTO users (id, email, name, password_hash, email_verified, role, created_at) 
VALUES (
    'admin_001', 
    'admin@cybercare.com', 
    'System Administrator', 
    'hashed_password_here', -- Replace with actual hashed password
    TRUE, 
    'admin', 
    NOW()
);

-- Create sample CERT viewer user
INSERT INTO users (id, email, name, password_hash, email_verified, role, created_at) 
VALUES (
    'cert_001', 
    'cert@cybercare.com', 
    'CERT Viewer', 
    'hashed_password_here', -- Replace with actual hashed password
    TRUE, 
    'cert_viewer', 
    NOW()
);

-- Add some sample data for testing (optional)
INSERT INTO threat_reports (id, title, description, links, submitted_by, status, submitted_at) 
VALUES (
    'report_001',
    'Suspicious Phishing Email',
    'Received an email claiming to be from PayPal asking for login credentials',
    ARRAY['http://fake-paypal-login.com'],
    'admin_001',
    'Pending',
    NOW()
);

-- Create views for common queries
CREATE VIEW user_report_summary AS
SELECT 
    u.id,
    u.name,
    u.email,
    COUNT(tr.id) as total_reports,
    COUNT(CASE WHEN tr.status = 'Validated' THEN 1 END) as validated_reports,
    COUNT(CASE WHEN tr.status = 'Pending' THEN 1 END) as pending_reports
FROM users u
LEFT JOIN threat_reports tr ON u.id = tr.submitted_by
WHERE u.role = 'user'
GROUP BY u.id, u.name, u.email;

CREATE VIEW breach_statistics AS
SELECT 
    COUNT(*) as total_scans,
    COUNT(CASE WHEN status = 'breached' THEN 1 END) as breached_count,
    COUNT(CASE WHEN status = 'clean' THEN 1 END) as clean_count,
    ROUND(
        COUNT(CASE WHEN status = 'breached' THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) as breach_percentage
FROM breach_scan_logs;

CREATE VIEW threat_report_dashboard AS
SELECT 
    status,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM threat_reports
GROUP BY status;

-- Trigger to update validated_at when status changes to validated
CREATE OR REPLACE FUNCTION update_validated_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IN ('Validated', 'False Alarm', 'Escalated') AND OLD.status = 'Pending' THEN
        NEW.validated_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_validated_at
    BEFORE UPDATE ON threat_reports
    FOR EACH ROW
    EXECUTE FUNCTION update_validated_at();

-- Function to clean old notifications (older than 30 days)
CREATE OR REPLACE FUNCTION cleanup_old_notifications()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM notifications 
    WHERE created_at < NOW() - INTERVAL '30 days' 
    AND status = 'seen';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions (adjust as needed)
-- CREATE ROLE cybercare_user WITH LOGIN PASSWORD 'your_password_here';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO cybercare_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO cybercare_user;