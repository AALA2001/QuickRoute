// modules/reports/virustotal_client.bal
import ballerina/http;
import ballerina/encoding;

configurable string vtApiKey = ?;

final http:Client vtClient = check new ("https://www.virustotal.com/api/v3", {
    headers: {
        "x-apikey": vtApiKey
    }
});

public type VTScanResult record {
    int positives;
    int total;
    string scan_date;
    record{} engines;
};

public isolated function scanUrl(string url) returns VTScanResult|error {
    // URL-safe base64 encoding
    string encodedUrl = encoding:encodeUriComponent(url, "UTF-8");
    string base64Url = encodedUrl.toBytes().toBase64();
    
    string endpoint = "/urls/" + base64Url;
    
    http:Response response = check vtClient->get(endpoint);
    json payload = check response.getJsonPayload();
    
    // Parse VT response and return structured result
    json attributes = <json>payload.data.attributes;
    json stats = <json>attributes.last_analysis_stats;
    
    return {
        positives: <int>stats.malicious + <int>stats.suspicious,
        total: <int>stats.harmless + <int>stats.malicious + <int>stats.suspicious + <int>stats.undetected,
        scan_date: <string>attributes.last_analysis_date,
        engines: <record{}>attributes.last_analysis_results
    };
}