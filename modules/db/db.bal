// Database Module for CyberCare
import ballerina/sql;
import ballerinax/postgresql;
import ballerina/log;

// Singleton database client
isolated postgresql:Client? dbClient = ();

// Initialize database connection
public isolated function initDB() returns error? {
    lock {
        if dbClient is () {
            postgresql:Client|error client = new (
                host = configurable string `CyberCare.database.host`,
                port = configurable int `CyberCare.database.port`,
                user = configurable string `CyberCare.database.username`,
                password = configurable string `CyberCare.database.password`,
                database = configurable string `CyberCare.database.database`
            );
            
            if client is error {
                log:printError("Failed to initialize database connection", client);
                return client;
            }
            
            dbClient = client;
            log:printInfo("Database connection initialized successfully");
        }
    }
}

// Get database client
public isolated function getDBClient() returns postgresql:Client|error {
    lock {
        if dbClient is postgresql:Client {
            return dbClient;
        } else {
            return error("Database client not initialized");
        }
    }
}

// Close database connection
public isolated function closeDB() returns error? {
    lock {
        if dbClient is postgresql:Client {
            check dbClient.close();
            dbClient = ();
            log:printInfo("Database connection closed");
        }
    }
}

// User Database Operations
public isolated function createUser(User user) returns error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        INSERT INTO users (id, email, name, password_hash, email_verified, role, created_at)
        VALUES (${user.id}, ${user.email}, ${user.name}, ${user.passwordHash}, 
                ${user.emailVerified}, ${user.role}, ${user.createdAt})
    `;
    
    sql:ExecutionResult result = check db->execute(query);
    log:printInfo("User created successfully", userId = user.id);
}

public isolated function getUserByEmail(string email) returns User|error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        SELECT id, email, name, password_hash, email_verified, role, created_at, last_login
        FROM users WHERE email = ${email}
    `;
    
    User|error? user = db->queryRow(query);
    return user;
}

public isolated function getUserById(string userId) returns User|error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        SELECT id, email, name, password_hash, email_verified, role, created_at, last_login
        FROM users WHERE id = ${userId}
    `;
    
    User|error? user = db->queryRow(query);
    return user;
}

public isolated function updateUserLastLogin(string userId) returns error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        UPDATE users SET last_login = NOW() WHERE id = ${userId}
    `;
    
    sql:ExecutionResult result = check db->execute(query);
}

// Breach Scan Log Operations
public isolated function createBreachScanLog(BreachScanLog log) returns error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        INSERT INTO breach_scan_logs (id, user_id, email, breached_in, scanned_at, status)
        VALUES (${log.id}, ${log.userId}, ${log.email}, ${log.breachedIn}, 
                ${log.scannedAt}, ${log.status})
    `;
    
    sql:ExecutionResult result = check db->execute(query);
}

public isolated function getBreachHistoryByUserId(string userId) returns BreachScanLog[]|error {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        SELECT id, user_id, email, breached_in, scanned_at, status
        FROM breach_scan_logs WHERE user_id = ${userId}
        ORDER BY scanned_at DESC
    `;
    
    stream<BreachScanLog, error?> resultStream = db->query(query);
    return from BreachScanLog log in resultStream select log;
}

// Threat Report Operations
public isolated function createThreatReport(ThreatReport report) returns error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        INSERT INTO threat_reports (id, title, description, links, evidence, submitted_by, 
                                  status, submitted_at)
        VALUES (${report.id}, ${report.title}, ${report.description}, ${report.links}, 
                ${report.evidence}, ${report.submittedBy}, ${report.status}, ${report.submittedAt})
    `;
    
    sql:ExecutionResult result = check db->execute(query);
}

public isolated function getAllThreatReports() returns ThreatReport[]|error {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        SELECT id, title, description, links, evidence, submitted_by, status, 
               submitted_at, validated_at, validated_by, remarks
        FROM threat_reports ORDER BY submitted_at DESC
    `;
    
    stream<ThreatReport, error?> resultStream = db->query(query);
    return from ThreatReport report in resultStream select report;
}

public isolated function getThreatReportById(string reportId) returns ThreatReport|error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        SELECT id, title, description, links, evidence, submitted_by, status, 
               submitted_at, validated_at, validated_by, remarks
        FROM threat_reports WHERE id = ${reportId}
    `;
    
    ThreatReport|error? report = db->queryRow(query);
    return report;
}

public isolated function updateThreatReportStatus(string reportId, string status, 
                                                string? validatedBy, string? remarks) returns error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        UPDATE threat_reports 
        SET status = ${status}, validated_at = NOW(), validated_by = ${validatedBy}, remarks = ${remarks}
        WHERE id = ${reportId}
    `;
    
    sql:ExecutionResult result = check db->execute(query);
}

public isolated function updateThreatReportVirusTotalResult(string reportId, 
                                                          VirusTotalResult vtResult) returns error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        UPDATE threat_reports 
        SET virustotal_result = ${vtResult.toJson()}
        WHERE id = ${reportId}
    `;
    
    sql:ExecutionResult result = check db->execute(query);
}

// Notification Operations
public isolated function createNotification(Notification notification) returns error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        INSERT INTO notifications (id, user_id, type, title, message, status, created_at, metadata)
        VALUES (${notification.id}, ${notification.userId}, ${notification.'type}, 
                ${notification.title}, ${notification.message}, ${notification.status}, 
                ${notification.createdAt}, ${notification.metadata})
    `;
    
    sql:ExecutionResult result = check db->execute(query);
}

public isolated function getNotificationsByUserId(string userId) returns Notification[]|error {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        SELECT id, user_id, type, title, message, status, created_at, metadata
        FROM notifications WHERE user_id = ${userId}
        ORDER BY created_at DESC
    `;
    
    stream<Notification, error?> resultStream = db->query(query);
    return from Notification notification in resultStream select notification;
}

public isolated function markNotificationAsSeen(string notificationId) returns error? {
    postgresql:Client db = check getDBClient();
    
    sql:ParameterizedQuery query = `
        UPDATE notifications SET status = 'seen' WHERE id = ${notificationId}
    `;
    
    sql:ExecutionResult result = check db->execute(query);
}

// Admin Dashboard Operations
public isolated function getAdminDashboardStats() returns AdminDashboardStats|error {
    postgresql:Client db = check getDBClient();
    
    // Get total reports
    sql:ParameterizedQuery totalReportsQuery = `SELECT COUNT(*) as count FROM threat_reports`;
    record {int count;} totalReportsResult = check db->queryRow(totalReportsQuery);
    
    // Get pending reports
    sql:ParameterizedQuery pendingQuery = `SELECT COUNT(*) as count FROM threat_reports WHERE status = 'Pending'`;
    record {int count;} pendingResult = check db->queryRow(pendingQuery);
    
    // Get validated reports
    sql:ParameterizedQuery validatedQuery = `SELECT COUNT(*) as count FROM threat_reports WHERE status = 'Validated'`;
    record {int count;} validatedResult = check db->queryRow(validatedQuery);
    
    // Get false alarms
    sql:ParameterizedQuery falseAlarmQuery = `SELECT COUNT(*) as count FROM threat_reports WHERE status = 'False Alarm'`;
    record {int count;} falseAlarmResult = check db->queryRow(falseAlarmQuery);
    
    // Get escalated reports
    sql:ParameterizedQuery escalatedQuery = `SELECT COUNT(*) as count FROM threat_reports WHERE status = 'Escalated'`;
    record {int count;} escalatedResult = check db->queryRow(escalatedQuery);
    
    // Get total users
    sql:ParameterizedQuery usersQuery = `SELECT COUNT(*) as count FROM users`;
    record {int count;} usersResult = check db->queryRow(usersQuery);
    
    // Get recent breaches (last 30 days)
    sql:ParameterizedQuery breachesQuery = `
        SELECT COUNT(*) as count FROM breach_scan_logs 
        WHERE status = 'breached' AND scanned_at >= NOW() - INTERVAL '30 days'
    `;
    record {int count;} breachesResult = check db->queryRow(breachesQuery);
    
    return {
        totalReports: totalReportsResult.count,
        pendingReports: pendingResult.count,
        validatedReports: validatedResult.count,
        falseAlarms: falseAlarmResult.count,
        escalatedReports: escalatedResult.count,
        totalUsers: usersResult.count,
        recentBreaches: breachesResult.count
    };
}