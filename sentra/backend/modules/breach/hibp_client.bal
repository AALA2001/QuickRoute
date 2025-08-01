// modules/breach/hibp_client.bal
import ballerina/http;
import ballerina/log;

configurable string hibpApiKey = ?;

final http:Client hibpClient = check new ("https://haveibeenpwned.com/api/v3", {
    headers: {
        "hibp-api-key": hibpApiKey,
        "User-Agent": "Sentra-App"
    }
});

public type BreachInfo record {
    string Name;
    string Title;
    string Domain;
    string BreachDate;
    string Description;
};

public isolated function checkEmailBreach(string email) returns BreachInfo[]|error {
    string endpoint = "/breachedaccount/" + email;
    
    http:Response|error response = hibpClient->get(endpoint);
    
    if response is error {
        log:printError("HIBP API call failed", response);
        return [];
    }
    
    if response.statusCode == 404 {
        return []; // No breaches found
    }
    
    if response.statusCode != 200 {
        return error("HIBP API returned status: " + response.statusCode.toString());
    }
    
    json|error payload = response.getJsonPayload();
    if payload is error {
        return error("Failed to parse HIBP response");
    }
    
    return <BreachInfo[]>payload;
}