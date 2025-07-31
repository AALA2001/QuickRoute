// HaveIBeenPwned API Integration Module for CyberCare
import ballerina/http;
import ballerina/log;
import ballerina/time;

// HIBP API Configuration
configurable string hibpApiKey = ?;
const string HIBP_BASE_URL = "https://haveibeenpwned.com/api/v3";

// HTTP client for HIBP API
http:Client hibpClient = check new (HIBP_BASE_URL, {
    timeout: 30,
    retryConfig: {
        count: 3,
        interval: 2
    },
    secureSocket: {
        enable: true
    }
});

// Check if email has been breached
public isolated function checkEmailBreach(string email) returns BreachScanLog|error {
    log:printInfo("Checking email breach for: " + email);
    
    map<string> headers = {
        "hibp-api-key": hibpApiKey,
        "User-Agent": "CyberCare-Platform"
    };
    
    string endpoint = "/breachedaccount/" + email + "?truncateResponse=false";
    
    http:Response|error response = hibpClient->get(endpoint, headers);
    
    if response is error {
        log:printError("HIBP API request failed", response);
        return error("Failed to check email breach status");
    }
    
    // Check if email was found in any breaches
    if response.statusCode == 404 {
        // No breaches found
        return createBreachScanLog(email, [], "clean");
    } else if response.statusCode == 200 {
        // Breaches found
        json|error jsonPayload = response.getJsonPayload();
        
        if jsonPayload is error {
            log:printError("Failed to parse HIBP response", jsonPayload);
            return error("Failed to parse breach check response");
        }
        
        if jsonPayload is json[] {
            string[] breachedSites = [];
            
            foreach json breach in jsonPayload {
                if breach is map<json> {
                    json siteName = breach["Name"];
                    if siteName is string {
                        breachedSites.push(siteName);
                    }
                }
            }
            
            return createBreachScanLog(email, breachedSites, "breached");
        } else {
            return createBreachScanLog(email, [], "clean");
        }
    } else if response.statusCode == 429 {
        // Rate limited
        log:printWarn("HIBP API rate limit exceeded");
        return error("API rate limit exceeded. Please try again later.");
    } else {
        log:printError("HIBP API returned unexpected status: " + response.statusCode.toString());
        return error("Unexpected error while checking breach status");
    }
}

// Get detailed breach information
public isolated function getBreachDetails(string breachName) returns HIBPBreachResponse|error {
    log:printInfo("Getting breach details for: " + breachName);
    
    map<string> headers = {
        "hibp-api-key": hibpApiKey,
        "User-Agent": "CyberCare-Platform"
    };
    
    string endpoint = "/breach/" + breachName;
    
    http:Response|error response = hibpClient->get(endpoint, headers);
    
    if response is error {
        log:printError("HIBP breach details request failed", response);
        return error("Failed to get breach details");
    }
    
    if response.statusCode == 200 {
        json|error jsonPayload = response.getJsonPayload();
        
        if jsonPayload is error {
            log:printError("Failed to parse HIBP breach details response", jsonPayload);
            return error("Failed to parse breach details response");
        }
        
        return parseBreachResponse(jsonPayload);
    } else if response.statusCode == 404 {
        return error("Breach not found");
    } else {
        log:printError("HIBP breach details API returned unexpected status: " + response.statusCode.toString());
        return error("Failed to retrieve breach details");
    }
}

// Get all breaches (for admin dashboard)
public isolated function getAllBreaches() returns HIBPBreachResponse[]|error {
    log:printInfo("Getting all breaches from HIBP");
    
    map<string> headers = {
        "hibp-api-key": hibpApiKey,
        "User-Agent": "CyberCare-Platform"
    };
    
    string endpoint = "/breaches";
    
    http:Response|error response = hibpClient->get(endpoint, headers);
    
    if response is error {
        log:printError("HIBP all breaches request failed", response);
        return error("Failed to get all breaches");
    }
    
    if response.statusCode == 200 {
        json|error jsonPayload = response.getJsonPayload();
        
        if jsonPayload is error {
            log:printError("Failed to parse HIBP all breaches response", jsonPayload);
            return error("Failed to parse all breaches response");
        }
        
        if jsonPayload is json[] {
            HIBPBreachResponse[] breaches = [];
            
            foreach json breach in jsonPayload {
                HIBPBreachResponse|error parsedBreach = parseBreachResponse(breach);
                if parsedBreach is HIBPBreachResponse {
                    breaches.push(parsedBreach);
                }
            }
            
            return breaches;
        } else {
            return error("Invalid response format from HIBP");
        }
    } else {
        log:printError("HIBP all breaches API returned unexpected status: " + response.statusCode.toString());
        return error("Failed to retrieve all breaches");
    }
}

// Helper function to create breach scan log
isolated function createBreachScanLog(string email, string[] breachedSites, string status) returns BreachScanLog {
    return {
        id: generateId("breach"),
        userId: "", // Will be set by calling service
        email: email,
        breachedIn: breachedSites,
        scannedAt: time:utcNow(),
        status: status
    };
}

// Helper function to parse HIBP breach response
isolated function parseBreachResponse(json breachJson) returns HIBPBreachResponse|error {
    if breachJson is map<json> {
        json name = breachJson["Name"];
        json title = breachJson["Title"];
        json domain = breachJson["Domain"];
        json breachDate = breachJson["BreachDate"];
        json pwnCount = breachJson["PwnCount"];
        json description = breachJson["Description"];
        json isVerified = breachJson["IsVerified"];
        json isFabricated = breachJson["IsFabricated"];
        json isSensitive = breachJson["IsSensitive"];
        json isRetired = breachJson["IsRetired"];
        json isSpamList = breachJson["IsSpamList"];
        json logoPath = breachJson["LogoPath"];
        json dataClasses = breachJson["DataClasses"];
        
        if !(name is string && title is string && domain is string && 
              breachDate is string && pwnCount is int && description is string &&
              isVerified is boolean && isFabricated is boolean && 
              isSensitive is boolean && isRetired is boolean && 
              isSpamList is boolean && logoPath is string)) {
            return error("Invalid breach data format");
        }
        
        string[] dataClassesArray = [];
        if dataClasses is json[] {
            foreach json dataClass in dataClasses {
                if dataClass is string {
                    dataClassesArray.push(dataClass);
                }
            }
        }
        
        return {
            Name: name,
            Title: title,
            Domain: domain,
            BreachDate: breachDate,
            PwnCount: pwnCount,
            Description: description,
            IsVerified: isVerified,
            IsFabricated: isFabricated,
            IsSensitive: isSensitive,
            IsRetired: isRetired,
            IsSpamList: isSpamList,
            LogoPath: logoPath,
            DataClasses: dataClassesArray
        };
    } else {
        return error("Invalid breach response format");
    }
}

// Perform breach check for user registration
public isolated function performRegistrationBreachCheck(string userId, string email) returns BreachScanLog|error {
    BreachScanLog scanLog = check checkEmailBreach(email);
    scanLog.userId = userId;
    
    // Save to database
    CyberCare.db:createBreachScanLog(scanLog);
    
    return scanLog;
}

// Check for breach when user changes email
public isolated function performEmailChangeBreachCheck(string userId, string newEmail) returns BreachScanLog|error {
    BreachScanLog scanLog = check checkEmailBreach(newEmail);
    scanLog.userId = userId;
    
    // Save to database
    CyberCare.db:createBreachScanLog(scanLog);
    
    return scanLog;
}