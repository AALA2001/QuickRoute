// main.bal
import ballerina/http;
import ballerina/cors;
import ballerina/time;
import ballerina/sql;
import sentra.auth;
import sentra.breach;
import sentra.reports;
import sentra.notifications;
import sentra.database;

listener http:Listener httpListener = new (8080, {
    cors: {
        allowOrigins: ["http://localhost:3000"],
        allowCredentials: true,
        allowHeaders: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    }
});

service /api on httpListener {
    
    // Health check endpoint
    resource function get health() returns json {
        return {
            status: "UP",
            service: "Sentra API",
            timestamp: time:utcNow()
        };
    }
    
    // Authentication endpoints
    resource function post signup(auth:SignupRequest request) returns auth:AuthResponse|http:BadRequest|error {
        auth:AuthResponse|error response = auth:registerUser(request);
        
        if response is error {
            return http:BAD_REQUEST;
        }
        
        // Trigger breach scan for new user
        _ = start breach:scanAndLogBreach(response.user.id, response.user.email);
        
        return response;
    }
    
    resource function post login(auth:LoginRequest request) returns auth:AuthResponse|http:Unauthorized|error {
        auth:AuthResponse|error response = auth:loginUser(request);
        
        if response is error {
            return http:UNAUTHORIZED;
        }
        
        return response;
    }
    
    // User profile endpoints
    resource function get me(http:RequestContext ctx, http:Request req) returns auth:User|http:Unauthorized|error {
        auth:User|error user = auth:authenticate(ctx, req);
        
        if user is error {
            return http:UNAUTHORIZED;
        }
        
        return user;
    }
    
    // Breach checking endpoints
    resource function get breach\-logs(http:RequestContext ctx, http:Request req) returns json[]|http:Unauthorized|error {
        auth:User|error user = auth:authenticate(ctx, req);
        if user is error {
            return http:UNAUTHORIZED;
        }
        
        return breach:getUserBreachLogs(user.id);
    }
    
    resource function post breach\-scan(http:RequestContext ctx, http:Request req) returns json|http:Unauthorized|error {
        auth:User|error user = auth:authenticate(ctx, req);
        if user is error {
            return http:UNAUTHORIZED;
        }
        
        _ = start breach:scanAndLogBreach(user.id, user.email);
        return {message: "Breach scan initiated"};
    }
    
    // Reports endpoints
    resource function post reports(http:RequestContext ctx, http:Request req, reports:ThreatReportRequest request) 
            returns json|http:Unauthorized|error {
        
        auth:User|error user = auth:authenticate(ctx, req);
        if user is error {
            return http:UNAUTHORIZED;
        }
        
        string|error reportId = reports:submitReport(request, user.id);
        if reportId is error {
            return error("Failed to submit report");
        }
        
        return {reportId: reportId, message: "Report submitted successfully"};
    }
    
    resource function get reports(http:RequestContext ctx, http:Request req) returns reports:ThreatReport[]|http:Unauthorized|error {
        auth:User|error user = auth:authenticate(ctx, req);
        if user is error {
            return http:UNAUTHORIZED;
        }
        
        return reports:getAllReports();
    }
    
    // Admin endpoints
    resource function get admin/reports(http:RequestContext ctx, http:Request req) 
            returns reports:ThreatReport[]|http:Unauthorized|error {
        
        auth:User|error user = auth:authenticate(ctx, req);
        if user is error || !isAdmin(user.id) {
            return http:UNAUTHORIZED;
        }
        
        return reports:getAllReports();
    }
    
    resource function put admin/reports/[string reportId]/validate(
            http:RequestContext ctx, 
            http:Request req,
            record {
                string status;
                string remarks?;
            } request) returns json|http:Unauthorized|error {
        
        auth:User|error user = auth:authenticate(ctx, req);
        if user is error || !isAdmin(user.id) {
            return http:UNAUTHORIZED;
        }
        
        error? result = reports:updateReportStatus(reportId, request.status, request.remarks, user.id);
        if result is error {
            return error("Failed to validate report");
        }
        
        return {message: "Report validated successfully"};
    }
    
    // Notifications endpoints
    resource function get notifications(http:RequestContext ctx, http:Request req) 
            returns notifications:Notification[]|http:Unauthorized|error {
        
        auth:User|error user = auth:authenticate(ctx, req);
        if user is error {
            return http:UNAUTHORIZED;
        }
        
        return notifications:getUserNotifications(user.id);
    }
    
    resource function put notifications/[string notificationId]/read(
            http:RequestContext ctx, 
            http:Request req) returns json|http:Unauthorized|error {
        
        auth:User|error user = auth:authenticate(ctx, req);
        if user is error {
            return http:UNAUTHORIZED;
        }
        
        error? result = notifications:markAsRead(notificationId, user.id);
        if result is error {
            return error("Failed to mark notification as read");
        }
        
        return {message: "Notification marked as read"};
    }
    
    resource function get notifications/unread\-count(http:RequestContext ctx, http:Request req) 
            returns json|http:Unauthorized|error {
        
        auth:User|error user = auth:authenticate(ctx, req);
        if user is error {
            return http:UNAUTHORIZED;
        }
        
        int|error count = notifications:getUnreadCount(user.id);
        if count is error {
            return error("Failed to get unread count");
        }
        
        return {count: count};
    }
}

// Helper function to check if user is admin
isolated function isAdmin(string userId) returns boolean {
    sql:Client|sql:Error dbClient = database:getConnection();
    if dbClient is sql:Error {
        return false;
    }
    
    sql:ParameterizedQuery query = `SELECT id FROM admins WHERE user_id = ${userId}`;
    stream<record{}, sql:Error?> resultStream = dbClient->query(query);
    record{}|error? result = resultStream.next();
    
    return result is record{};
}