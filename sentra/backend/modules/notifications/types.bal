// modules/notifications/types.bal

public type NotificationRequest record {
    string userId;
    string type; // breach_detected, report_update, system_alert
    string title;
    string message;
};

public type Notification record {
    string id;
    string user_id;
    string type;
    string title;
    string message;
    string status; // unread, read
    string created_at;
};