import ballerina/http;
import ballerina/mime;

public function setErrorResponse(http:Response response, string|json message) returns http:Response {
    response.setJsonPayload({"success": false, "content": message});
    return response;
}

public isolated function validateImageFile(mime:Entity part) returns boolean {
    string contentType = part.getContentType();
    if contentType == "image/jpeg" || contentType == "image/png" {
        return true;
    }
    return false;
}

public isolated function validateContentType(string contentType) returns boolean {
    return contentType.startsWith("multipart/form-data");
}

public function response(boolean status, string message) returns json {
    return {"success": status, "content": message};
}
