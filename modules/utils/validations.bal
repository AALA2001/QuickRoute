import ballerina/mime;
import ballerina/http;
public function validateContentType(http:Request req) returns boolean {
    string|error contentType = req.getContentType();
    return contentType is string && contentType.startsWith(MULTIPART_FORM_DATA);
}

public function setErrorResponse(http:Response response, string|json message) returns http:Response {
    response.setJsonPayload({"success": false, "content": message});
    return response;
}

public function validateImageFile(mime:Entity part) returns boolean {
    string|mime:ParserError contentType = part.getContentType();
    return contentType is string && string:startsWith(contentType, "image/");
}

public function response(boolean status, string message) returns json {
    return {"success": status, "content": message};
}
