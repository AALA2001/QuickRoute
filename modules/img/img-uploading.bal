import ballerina/time;
import ballerina/io;
import ballerina/mime;
import ballerina/http;
import ballerina/regex;

public function uploadImage(http:Request req, string path, string fileName) returns string|error {
    mime:Entity[] parts = check req.getBodyParts();

    if parts.length() > 0 {
        foreach mime:Entity part in parts {
            if part.getContentDisposition().name == "file" {
                string originalFileName = part.getContentDisposition().fileName;

                string fileExtention = "";
                int? index = originalFileName.lastIndexOf(".");
                if index is int {
                    fileExtention = originalFileName.substring(index);
                }

                time:Civil civilTime = time:utcToCivil(time:utcNow());
                string currentTimeString = civilTime.hour.toString() + civilTime.minute.toString() + civilTime.second.toString();
                string[] spliited = regex:split(currentTimeString, "\\.");
                string timeMil = spliited[0] + "" + spliited[1];

                string newFileName = fileName+"_" + timeMil + fileExtention;
                string filePath = "./"+path + newFileName;
                byte[] fileContent = check part.getByteArray();

                check io:fileWriteBytes(filePath, fileContent);
                return path + newFileName;
            }
        }
    }
    return error("No file found in the request");
}
