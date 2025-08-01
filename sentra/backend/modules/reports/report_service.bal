// modules/reports/report_service.bal
import sentra.database;
import sentra.notifications;
import ballerina/sql;
import ballerinax/mysql;

public isolated function submitReport(ThreatReportRequest request, string userId) returns string|error {
    mysql:Client dbClient = check database:getConnection();
    string reportId = database:generateId();
    
    json linksJson = request.links?.toJson() ?: [];
    
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO threat_reports (id, title, description, links, evidence, submitted_by)
        VALUES (${reportId}, ${request.title}, ${request.description}, ${linksJson}, ${request.evidence}, ${userId})
    `;
    
    _ = check dbClient->execute(insertQuery);
    
    // Trigger async validation if URLs are present
    if request.links is string[] && request.links.length() > 0 {
        _ = start validateReportAsync(reportId, request.links);
    }
    
    return reportId;
}

isolated function validateReportAsync(string reportId, string[] urls) returns error? {
    int totalPositives = 0;
    int totalScans = 0;
    json scanResults = {};
    
    // Scan each URL
    foreach string url in urls {
        VTScanResult|error result = scanUrl(url);
        
        if result is VTScanResult {
            totalPositives += result.positives;
            totalScans += result.total;
            scanResults = {
                ...scanResults,
                [url]: result
            };
        }
    }
    
    // Determine status based on scan results
    string newStatus = "Pending";
    if totalPositives > 3 {
        newStatus = "Validated";
    } else if totalPositives > 0 {
        newStatus = "Needs_Review";
    }
    
    // Update report in database
    mysql:Client dbClient = check database:getConnection();
    sql:ParameterizedQuery updateQuery = `
        UPDATE threat_reports 
        SET virus_total_result = ${scanResults}, status = ${newStatus}
        WHERE id = ${reportId}
    `;
    
    _ = check dbClient->execute(updateQuery);
    
    // Notify user of validation result
    _ = check notifyUserOfValidation(reportId, newStatus);
}

isolated function notifyUserOfValidation(string reportId, string status) returns error? {
    mysql:Client dbClient = check database:getConnection();
    
    sql:ParameterizedQuery query = `
        SELECT submitted_by, title FROM threat_reports WHERE id = ${reportId}
    `;
    
    stream<record{}, sql:Error?> resultStream = dbClient->query(query);
    record{}|error? result = resultStream.next();
    
    if result is record{} {
        string userId = <string>result["submitted_by"];
        string title = <string>result["title"];
        
        _ = check notifications:createNotification({
            userId: userId,
            type: "report_update",
            title: "Report Validation Update",
            message: string `Your report "${title}" has been ${status.toLowerAscii()}.`
        });
    }
}

public isolated function getAllReports() returns ThreatReport[]|error {
    mysql:Client dbClient = check database:getConnection();
    
    sql:ParameterizedQuery query = `
        SELECT id, title, description, links, evidence, status, submitted_by, 
               virus_total_result, admin_remarks, validated_by, created_at, updated_at
        FROM threat_reports 
        ORDER BY created_at DESC
    `;
    
    stream<record{}, sql:Error?> resultStream = dbClient->query(query);
    ThreatReport[] reports = [];
    
    error? e = resultStream.forEach(function(record{} row) {
        ThreatReport report = {
            id: <string>row["id"],
            title: <string>row["title"],
            description: <string>row["description"],
            links: <json>row["links"],
            evidence: <string?>row["evidence"],
            status: <string>row["status"],
            submitted_by: <string>row["submitted_by"],
            virus_total_result: <json?>row["virus_total_result"],
            admin_remarks: <string?>row["admin_remarks"],
            validated_by: <string?>row["validated_by"],
            created_at: <string>row["created_at"],
            updated_at: <string>row["updated_at"]
        };
        reports.push(report);
    });
    
    if e is error {
        return error("Failed to fetch reports");
    }
    
    return reports;
}

public isolated function updateReportStatus(string reportId, string status, string? remarks, string validatedBy) returns error? {
    mysql:Client dbClient = check database:getConnection();
    
    sql:ParameterizedQuery updateQuery = `
        UPDATE threat_reports 
        SET status = ${status}, admin_remarks = ${remarks}, validated_by = ${validatedBy}
        WHERE id = ${reportId}
    `;
    
    _ = check dbClient->execute(updateQuery);
    
    // Notify user of manual validation
    _ = check notifyUserOfValidation(reportId, status);
}