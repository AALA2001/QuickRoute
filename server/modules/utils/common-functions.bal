import ballerina/mime;
import ballerina/http;
public isolated function returnResponseWithStatusCode(http:Response res, int statusCode, string|json message, boolean status = false) returns http:Response {
    res.statusCode = statusCode;
    res.setJsonPayload({"success": status, "message": message});
    return res;
}

public isolated function parseMultipartFormData(mime:Entity[]|http:ClientError bodyParts, map<any> formData) returns map<any>|error {
    if bodyParts is mime:Entity[] {
        foreach mime:Entity part in bodyParts {
            string partName = part.getContentDisposition().name;
            if part.getContentType().startsWith("image/") && validateImageFile(part) {
                byte[]|mime:ParserError byteArray = part.getByteArray();
                if byteArray is byte[] {
                    formData[partName] = byteArray;
                }
            } else {
                string|mime:ParserError text = part.getText();
                if text is string {
                    formData[partName] = text;
                }
            }
        }
    } else {
        return error("Failed to parse multipart request");
    }
    return formData;
}
