// CyberCare Type Definitions

import ballerina/time;

// User Management Types
public type User record {
    string id;
    string email;
    string name;
    string passwordHash;
    boolean emailVerified = false;
    string role = "user"; // "user", "admin", "cert_viewer"
    time:Utc createdAt;
    time:Utc? lastLogin = ();
};

public type UserSignupRequest record {
    string email;
    string password;
    string name;
};

public type UserLoginRequest record {
    string email;
    string password;
};

public type UserProfile record {
    string id;
    string email;
    string name;
    BreachScanLog[] breachHistory;
    boolean emailVerified;
    time:Utc createdAt;
};

// Breach Scanning Types
public type BreachScanLog record {
    string id;
    string userId;
    string email;
    string[] breachedIn;
    time:Utc scannedAt;
    string status; // "clean", "breached"
};

public type HIBPBreachResponse record {
    string Name;
    string Title;
    string Domain;
    string BreachDate;
    int PwnCount;
    string Description;
    boolean IsVerified;
    boolean IsFabricated;
    boolean IsSensitive;
    boolean IsRetired;
    boolean IsSpamList;
    string LogoPath;
    string[] DataClasses;
};

// Threat Reporting Types
public type ThreatReport record {
    string id;
    string title;
    string description;
    string[] links;
    string? evidence; // Base64 encoded image
    string submittedBy;
    string status; // "Pending", "Validated", "False Alarm", "Escalated"
    time:Utc submittedAt;
    time:Utc? validatedAt = ();
    string? validatedBy = ();
    string? remarks = ();
    VirusTotalResult? virusTotalResult = ();
};

public type ThreatReportRequest record {
    string title;
    string description;
    string[] links;
    string? evidence;
};

public type ThreatValidationRequest record {
    string status;
    string? remarks;
};

// VirusTotal Integration Types
public type VirusTotalResult record {
    int positives;
    int total;
    time:Utc scanDate;
    string scanId;
    string permalink;
    json rawResponse;
};

public type VirusTotalURLScanResponse record {
    int response_code;
    string verbose_msg;
    string resource;
    string scan_id;
    string permalink;
    string scan_date;
    int positives;
    int total;
    json scans;
};

// Notification Types
public type Notification record {
    string id;
    string userId;
    string 'type; // "breach_detected", "report_status_change", "general"
    string title;
    string message;
    string status; // "unseen", "seen"
    time:Utc createdAt;
    json? metadata = ();
};

public type EmailNotification record {
    string to;
    string subject;
    string body;
    string? htmlBody = ();
};

// CERT Integration Types
public type CERTExportData record {
    string reportId;
    string title;
    string description;
    string[] maliciousLinks;
    VirusTotalResult? scanEvidence;
    time:Utc validatedAt;
    string validatedBy;
    string exportedBy;
    time:Utc exportedAt;
};

// Admin Types
public type AdminDashboardStats record {
    int totalReports;
    int pendingReports;
    int validatedReports;
    int falseAlarms;
    int escalatedReports;
    int totalUsers;
    int recentBreaches;
};

// API Response Types
public type APIResponse record {
    boolean success;
    string message;
    json? data = ();
    string? 'error = ();
};

public type AuthResponse record {
    boolean success;
    string message;
    string? token = ();
    UserProfile? user = ();
};

// JWT Claims
public type JWTClaims record {
    string sub; // user ID
    string email;
    string name;
    string role;
    int exp;
    int iat;
    string iss;
};

// Validation and Error Types
public type ValidationError record {
    string 'field;
    string message;
};

public enum ReportStatus {
    PENDING = "Pending",
    VALIDATED = "Validated",
    FALSE_ALARM = "False Alarm",
    ESCALATED = "Escalated"
}

public enum UserRole {
    USER = "user",
    ADMIN = "admin",
    CERT_VIEWER = "cert_viewer"
}

public enum NotificationType {
    BREACH_DETECTED = "breach_detected",
    REPORT_STATUS_CHANGE = "report_status_change",
    GENERAL = "general"
}