import ballerina/http;
import ballerina/log;

const string apiUrl = "https://api.openai.com/v1/chat/completions";
const string apiKey = "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";

type Message record {
    string role;
    string content;
};

type RequestBody record {
    string model;
    Message[] messages;
};

service /openai on new http:Listener(8080) {

    resource function post generateText(http:Caller caller, http:Request req) returns error? {
        RequestBody requestBody = {
            model: "gpt-3.5-turbo-0125",
            messages: [
                { role: "user", content: "Tell me about ballerina programming language" }
            ]
        };
        http:Client openAIClient = check new(apiUrl, {
            auth: {
                token: apiKey 
            }
        });
        http:Response|http:ClientError response = openAIClient->post("", requestBody);
        if (response is http:Response) {
            json jsonResponse = check response.getJsonPayload();
            log:printInfo("Generated text: " + jsonResponse.toString());
            check caller->respond(jsonResponse);
        } else {
            check caller->respond("Error occurred while generating text.");
        }
    }
}