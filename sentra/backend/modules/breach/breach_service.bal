// modules/breach/breach_service.bal
import sentra.database;
import sentra.notifications;
import ballerina/sql;
import ballerinax/mysql;

public isolated function scanAndLogBreach(string userId, string email) returns error? {
    BreachInfo[] breaches = check checkEmailBreach(email);
    
    mysql:Client dbClient = check database:getConnection();
    string logId = database:generateId();
    
    json breachesJson = breaches.toJson();
    
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO breach_scan_logs (id, user_id, email, breached_services, scanned_at)
        VALUES (${logId}, ${userId}, ${email}, ${breachesJson}, NOW())
    `;
    
    _ = check dbClient->execute(insertQuery);
    
    // Create notification if breaches found
    if breaches.length() > 0 {
        string message = string `Your email was found in ${breaches.length()} data breach(es). Please review and change your passwords for affected services.`;
        
        _ = check notifications:createNotification({
            userId: userId,
            type: "breach_detected",
            title: "Data Breach Alert",
            message: message
        });
    }
}

public isolated function getUserBreachLogs(string userId) returns json[]|error {
    mysql:Client dbClient = check database:getConnection();
    
    sql:ParameterizedQuery query = `
        SELECT id, email, breached_services, scanned_at 
        FROM breach_scan_logs 
        WHERE user_id = ${userId} 
        ORDER BY scanned_at DESC
    `;
    
    stream<record{}, sql:Error?> resultStream = dbClient->query(query);
    json[] logs = [];
    
    error? e = resultStream.forEach(function(record{} row) {
        logs.push(row.toJson());
    });
    
    if e is error {
        return error("Failed to fetch breach logs");
    }
    
    return logs;
}