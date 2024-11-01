import ballerina/http;

configurable string API_URL = ?;
configurable string API_TOKEN = ?;

public isolated function generateText(string query) returns json|error? {
    json requestBody = {
        model: "gpt-3.5-turbo-0125",
        messages: [
            { role: "user", content: query }
        ]
    };

    http:Client openAIClient = check new(API_URL, {
        auth: {
            token: API_TOKEN
        }
    });

    http:Response|http:ClientError response = openAIClient->post("", requestBody);
    if (response is http:Response) {
        json jsonResponse = check response.getJsonPayload();
        return jsonResponse;
    } else {
        return error("Error occurred while generating text.");
    }
}