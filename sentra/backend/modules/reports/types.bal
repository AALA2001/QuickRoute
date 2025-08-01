// modules/reports/types.bal

public type ThreatReportRequest record {
    string title;
    string description;
    string[] links?;
    string evidence?; // Base64 encoded image
};

public type ThreatReport record {
    string id;
    string title;
    string description;
    json links;
    string? evidence;
    string status;
    string submitted_by;
    json? virus_total_result;
    string? admin_remarks;
    string? validated_by;
    string created_at;
    string updated_at;
};