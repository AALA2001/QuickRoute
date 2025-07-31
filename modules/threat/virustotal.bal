// VirusTotal API Integration Module for CyberCare
import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/url;
import ballerina/regex;

// VirusTotal API Configuration
configurable string virusTotalApiKey = ?;
const string VT_BASE_URL = "https://www.virustotal.com/api/v3";

// HTTP client for VirusTotal API
http:Client vtClient = check new (VT_BASE_URL, {
    timeout: 60,
    retryConfig: {
        count: 3,
        interval: 5
    },
    secureSocket: {
        enable: true
    }
});

// Validate URLs from threat report
public isolated function validateThreatUrls(string[] urls) returns VirusTotalResult|error {
    if urls.length() == 0 {
        return error("No URLs provided for validation");
    }
    
    log:printInfo("Validating " + urls.length().toString() + " URLs with VirusTotal");
    
    int totalPositives = 0;
    int totalScans = 0;
    string scanId = "";
    string permalink = "";
    json[] allResults = [];
    
    foreach string targetUrl in urls {
        VirusTotalURLScanResponse|error result = check scanUrl(targetUrl);
        
        if result is VirusTotalURLScanResponse {
            totalPositives += result.positives;
            totalScans += result.total;
            scanId = result.scan_id;
            permalink = result.permalink;
            allResults.push(result.scans);
        }
    }
    
    return {
        positives: totalPositives,
        total: totalScans,
        scanDate: time:utcNow(),
        scanId: scanId,
        permalink: permalink,
        rawResponse: allResults
    };
}

// Scan a single URL with VirusTotal
public isolated function scanUrl(string targetUrl) returns VirusTotalURLScanResponse|error {
    log:printInfo("Scanning URL with VirusTotal: " + targetUrl);
    
    // First, submit URL for scanning
    string|error submitResult = check submitUrlForScanning(targetUrl);
    
    if submitResult is error {
        return submitResult;
    }
    
    // Wait a bit before getting results
    runtime:sleep(3);
    
    // Get scan results
    return check getUrlScanResults(targetUrl);
}

// Submit URL to VirusTotal for scanning
isolated function submitUrlForScanning(string targetUrl) returns string|error {
    map<string> headers = {
        "x-apikey": virusTotalApiKey,
        "Content-Type": "application/x-www-form-urlencoded"
    };
    
    string encodedUrl = check url:encode(targetUrl, "UTF-8");
    string payload = "url=" + encodedUrl;
    
    http:Response|error response = vtClient->post("/urls", payload, headers);
    
    if response is error {
        log:printError("VirusTotal URL submission failed", response);
        return error("Failed to submit URL for scanning");
    }
    
    if response.statusCode == 200 {
        json|error jsonPayload = response.getJsonPayload();
        
        if jsonPayload is error {
            log:printError("Failed to parse VirusTotal submission response", jsonPayload);
            return error("Failed to parse scan submission response");
        }
        
        if jsonPayload is map<json> {
            json data = jsonPayload["data"];
            if data is map<json> {
                json id = data["id"];
                if id is string {
                    return id;
                }
            }
        }
        
        return error("Invalid response format from VirusTotal");
    } else {
        log:printError("VirusTotal URL submission returned unexpected status: " + response.statusCode.toString());
        return error("Failed to submit URL for scanning");
    }
}

// Get URL scan results from VirusTotal
isolated function getUrlScanResults(string targetUrl) returns VirusTotalURLScanResponse|error {
    // Encode URL to base64 for the API call
    string base64Url = (targetUrl.toBytes()).toBase64();
    // URL-safe base64 encoding
    string urlSafeBase64 = regex:replaceAll(base64Url, "\\+", "-");
    urlSafeBase64 = regex:replaceAll(urlSafeBase64, "/", "_");
    urlSafeBase64 = regex:replaceAll(urlSafeBase64, "=", "");
    
    map<string> headers = {
        "x-apikey": virusTotalApiKey
    };
    
    string endpoint = "/urls/" + urlSafeBase64;
    
    http:Response|error response = vtClient->get(endpoint, headers);
    
    if response is error {
        log:printError("VirusTotal URL scan results request failed", response);
        return error("Failed to get URL scan results");
    }
    
    if response.statusCode == 200 {
        json|error jsonPayload = response.getJsonPayload();
        
        if jsonPayload is error {
            log:printError("Failed to parse VirusTotal scan results response", jsonPayload);
            return error("Failed to parse scan results response");
        }
        
        return parseUrlScanResponse(jsonPayload, targetUrl);
    } else if response.statusCode == 404 {
        log:printInfo("URL not found in VirusTotal database, might be clean: " + targetUrl);
        // Return a clean result for URLs not in VT database
        return {
            response_code: 1,
            verbose_msg: "URL not found in VirusTotal database",
            resource: targetUrl,
            scan_id: "",
            permalink: "",
            scan_date: time:utcNow().toString(),
            positives: 0,
            total: 0,
            scans: {}
        };
    } else {
        log:printError("VirusTotal scan results API returned unexpected status: " + response.statusCode.toString());
        return error("Failed to retrieve scan results");
    }
}

// Parse VirusTotal URL scan response
isolated function parseUrlScanResponse(json responseJson, string originalUrl) returns VirusTotalURLScanResponse|error {
    if responseJson is map<json> {
        json data = responseJson["data"];
        
        if data is map<json> {
            json attributes = data["attributes"];
            
            if attributes is map<json> {
                json lastAnalysisStats = attributes["last_analysis_stats"];
                json lastAnalysisResults = attributes["last_analysis_results"];
                
                if lastAnalysisStats is map<json> && lastAnalysisResults is map<json> {
                    json malicious = lastAnalysisStats["malicious"];
                    json suspicious = lastAnalysisStats["suspicious"];
                    json harmless = lastAnalysisStats["harmless"];
                    json undetected = lastAnalysisStats["undetected"];
                    json timeout = lastAnalysisStats["timeout"];
                    
                    if !(malicious is int && suspicious is int && harmless is int && 
                          undetected is int && timeout is int)) {
                        return error("Invalid analysis stats format");
                    }
                    
                    int positives = malicious + suspicious;
                    int total = malicious + suspicious + harmless + undetected + timeout;
                    
                    return {
                        response_code: 1,
                        verbose_msg: "Scan completed",
                        resource: originalUrl,
                        scan_id: data["id"].toString(),
                        permalink: "https://www.virustotal.com/gui/url/" + data["id"].toString(),
                        scan_date: time:utcNow().toString(),
                        positives: positives,
                        total: total,
                        scans: lastAnalysisResults
                    };
                }
            }
        }
    }
    
    return error("Invalid VirusTotal response format");
}

// Extract URLs from threat report text
public isolated function extractUrlsFromText(string text) returns string[] {
    // Simple URL extraction using regex
    string[] urls = [];
    
    // Regex pattern for URLs
    string urlPattern = "https?://[\\w\\-]+(\\.[\\w\\-]+)+([\\w\\-\\.,@?^=%&:/~\\+#]*[\\w\\-\\@?^=%&/~\\+#])?";
    
    regex:RegExp|error urlRegex = regex:fromString(urlPattern);
    
    if urlRegex is regex:RegExp {
        regex:Span[]? matches = urlRegex.findAll(text);
        
        if matches is regex:Span[] {
            foreach regex:Span match in matches {
                string url = text.substring(match.startIndex, match.endIndex);
                urls.push(url);
            }
        }
    }
    
    return urls;
}

// Auto-classify threat based on VirusTotal results
public isolated function classifyThreat(VirusTotalResult vtResult) returns string {
    if vtResult.positives >= 3 {
        return "Validated"; // High confidence malicious
    } else if vtResult.positives >= 1 {
        return "Pending"; // Needs manual review
    } else {
        return "False Alarm"; // Likely clean
    }
}

// Process threat report with VirusTotal validation
public isolated function processThreatWithVirusTotal(ThreatReport report) returns ThreatReport|error {
    // Extract URLs from description and links
    string[] allUrls = report.links.clone();
    string[] extractedUrls = extractUrlsFromText(report.description);
    
    foreach string extractedUrl in extractedUrls {
        allUrls.push(extractedUrl);
    }
    
    // Remove duplicates
    string[] uniqueUrls = [];
    foreach string url in allUrls {
        if uniqueUrls.indexOf(url) is () {
            uniqueUrls.push(url);
        }
    }
    
    if uniqueUrls.length() > 0 {
        log:printInfo("Processing threat report " + report.id + " with " + uniqueUrls.length().toString() + " URLs");
        
        VirusTotalResult|error vtResult = validateThreatUrls(uniqueUrls);
        
        if vtResult is VirusTotalResult {
            // Update report with VirusTotal results
            report.virusTotalResult = vtResult;
            
            // Auto-classify based on results
            string autoStatus = classifyThreat(vtResult);
            report.status = autoStatus;
            
            // Update in database
            CyberCare.db:updateThreatReportVirusTotalResult(report.id, vtResult);
            CyberCare.db:updateThreatReportStatus(report.id, autoStatus, "system", 
                "Auto-classified based on VirusTotal scan results");
            
            log:printInfo("Threat report " + report.id + " auto-classified as: " + autoStatus);
        } else {
            log:printError("VirusTotal validation failed for report " + report.id, vtResult);
        }
    } else {
        log:printInfo("No URLs found in threat report " + report.id + " for VirusTotal validation");
    }
    
    return report;
}

// Bulk validate multiple threat reports
public isolated function bulkValidateThreats(ThreatReport[] reports) returns ThreatReport[]|error {
    ThreatReport[] processedReports = [];
    
    foreach ThreatReport report in reports {
        if report.status == "Pending" {
            ThreatReport|error processedReport = processThreatWithVirusTotal(report);
            
            if processedReport is ThreatReport {
                processedReports.push(processedReport);
            } else {
                log:printError("Failed to process threat report " + report.id, processedReport);
                processedReports.push(report); // Keep original if processing fails
            }
            
            // Rate limiting - wait between requests
            runtime:sleep(1);
        } else {
            processedReports.push(report);
        }
    }
    
    return processedReports;
}

// Get VirusTotal scan quota information
public isolated function getApiQuota() returns json|error {
    map<string> headers = {
        "x-apikey": virusTotalApiKey
    };
    
    http:Response|error response = vtClient->get("/users/" + virusTotalApiKey, headers);
    
    if response is error {
        log:printError("VirusTotal quota check failed", response);
        return error("Failed to check API quota");
    }
    
    if response.statusCode == 200 {
        json|error jsonPayload = response.getJsonPayload();
        
        if jsonPayload is error {
            log:printError("Failed to parse VirusTotal quota response", jsonPayload);
            return error("Failed to parse quota response");
        }
        
        return jsonPayload;
    } else {
        return error("Failed to retrieve API quota information");
    }
}