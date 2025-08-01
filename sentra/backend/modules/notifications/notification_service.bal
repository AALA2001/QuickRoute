// modules/notifications/notification_service.bal
import sentra.database;
import ballerina/sql;
import ballerinax/mysql;

public isolated function createNotification(NotificationRequest request) returns string|error {
    mysql:Client dbClient = check database:getConnection();
    string notificationId = database:generateId();
    
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO notifications (id, user_id, type, title, message)
        VALUES (${notificationId}, ${request.userId}, ${request.type}, ${request.title}, ${request.message})
    `;
    
    _ = check dbClient->execute(insertQuery);
    
    return notificationId;
}

public isolated function getUserNotifications(string userId) returns Notification[]|error {
    mysql:Client dbClient = check database:getConnection();
    
    sql:ParameterizedQuery query = `
        SELECT id, user_id, type, title, message, status, created_at 
        FROM notifications 
        WHERE user_id = ${userId} 
        ORDER BY created_at DESC
    `;
    
    stream<record{}, sql:Error?> resultStream = dbClient->query(query);
    Notification[] notifications = [];
    
    error? e = resultStream.forEach(function(record{} row) {
        Notification notification = {
            id: <string>row["id"],
            user_id: <string>row["user_id"],
            type: <string>row["type"],
            title: <string>row["title"],
            message: <string>row["message"],
            status: <string>row["status"],
            created_at: <string>row["created_at"]
        };
        notifications.push(notification);
    });
    
    if e is error {
        return error("Failed to fetch notifications");
    }
    
    return notifications;
}

public isolated function markAsRead(string notificationId, string userId) returns error? {
    mysql:Client dbClient = check database:getConnection();
    
    sql:ParameterizedQuery updateQuery = `
        UPDATE notifications 
        SET status = 'read' 
        WHERE id = ${notificationId} AND user_id = ${userId}
    `;
    
    _ = check dbClient->execute(updateQuery);
}

public isolated function getUnreadCount(string userId) returns int|error {
    mysql:Client dbClient = check database:getConnection();
    
    sql:ParameterizedQuery query = `
        SELECT COUNT(*) as count 
        FROM notifications 
        WHERE user_id = ${userId} AND status = 'unread'
    `;
    
    stream<record{}, sql:Error?> resultStream = dbClient->query(query);
    record{}|error? result = resultStream.next();
    
    if result is record{} {
        return <int>result["count"];
    }
    
    return 0;
}