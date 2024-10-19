import QuickRoute.db;
// import QuickRoute.img;
import QuickRoute.jwt;
import QuickRoute.password;
import QuickRoute.time;
import QuickRoute.utils;

import ballerina/http;
import ballerina/io;
import ballerina/mime;
import ballerina/regex;
import ballerina/sql;
import ballerinax/mysql;

http:ClientConfiguration authEPConfig = {
    cookieConfig: {
        enabled: true
    }
};
listener http:Listener mainEP = new (9091);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE"],
        allowCredentials: true
    }
}
service / on mainEP {
    resource function get [string folderName]/[string imageName]() returns http:Response|error {
        string imagePath = "resources/uploads/" + folderName + "/" + imageName;
        byte[] imageContent = check io:fileReadBytes(imagePath);
        http:Response res = new;
        res.setPayload(imageContent);
        if (imageName.endsWith(".png")) {
            res.setHeader(http:CONTENT_TYPE, mime:IMAGE_PNG.toString());
        } else if (imageName.endsWith(".jpg") || imageName.endsWith(".jpeg")) {
            res.setHeader(http:CONTENT_TYPE, mime:IMAGE_JPEG.toString());
        } else {
            res.setHeader(http:CONTENT_TYPE, "application/octet-stream");
        }
        return res;
    }
}

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE"],
        allowCredentials: true
    }
}
service /auth on mainEP {
    private final mysql:Client connection;

    function init() returns error? {
        self.connection = db:getConnection();
    }

    function __deinit() returns sql:Error? {
        _ = checkpanic self.connection.close();
    }

    resource function post user/register(@http:Payload RequestUser user) returns http:Response|http:Unauthorized|error {
        http:Response response = new;
        json responseObj = {};
        map<string> errorMsg = {};

        boolean errorFlag = false;

        if user.first_name is "" {
            errorFlag = true;
            errorMsg["first_name"] = utils:EMAIL_REQUIRED;
        } else if user.first_name.length() > 45 {
            errorFlag = true;
            errorMsg["first_name"] = utils:FNAME_LENGTH;
        }

        if user.last_name is "" {
            errorFlag = true;
            errorMsg["last_name"] = utils:LNAME_REQUIRED;
        } else if user.last_name.length() > 45 {
            errorFlag = true;
            errorMsg["last_name"] = utils:LNAME_LENGTH;
        }

        if user.email is "" {
            errorFlag = true;
            errorMsg["email"] = utils:EMAIL_REQUIRED;
        } else if user.email.length() > 200 {
            errorFlag = true;
            errorMsg["email"] = utils:EMAIL_LENGTH;
        } else if !regex:matches(user.email, utils:EMAIL_REGEX) {
            errorFlag = true;
            errorMsg["email"] = utils:EMAIL_INVALID_FORMAT;
        }

        if user.password is "" {
            errorFlag = true;
            errorMsg["password"] = utils:PASSWORD_REQUIRED;
        } else if !regex:matches(user.password, utils:PASSWORD_REGEX) {
            errorFlag = true;
            errorMsg["password"] = utils:PASSWORD_LENGTH;
        }

        if errorFlag {
            responseObj = {"success": false, "content": errorMsg.toJson()};
        } else {
            string hashedPassword = password:generateHmac(user.password);
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = ${user.email}`);
            if result is sql:NoRowsError {
                _ = check self.connection->execute(`INSERT INTO user (first_name,last_name,email,password)  VALUES (${user.first_name}, ${user.last_name}, ${user.email}, ${hashedPassword});`);
                UserDTO UserDTO = {
                    first_name: user.first_name,
                    last_name: user.last_name,
                    email: user.email,
                    userType: "user",
                    expiryTime: time:expierTimeStamp()
                };
                string token = check jwt:generateJWT(UserDTO.toJsonString());
                responseObj = {"success": true, "content": "Successfully Registered", "token": token};
            } else {
                responseObj = {"success": false, "content": "User already exists"};
            }
        }
        response.setJsonPayload(responseObj);
        return response;
    }

    resource function post user/login(@http:Payload LoginUser user) returns http:Response|http:Unauthorized|error {
        http:Response response = new;
        json responseObj = {};
        map<string> errorMsg = {};
        boolean errorFlag = false;

        if user.email is "" {
            errorFlag = true;
            errorMsg["email"] = utils:EMAIL_REQUIRED;
        } else if !regex:matches(user.email, utils:EMAIL_REGEX) {
            errorFlag = true;
            errorMsg["email"] = utils:EMAIL_INVALID_FORMAT;
        }

        if user.password is "" {
            errorFlag = true;
            errorMsg["password"] = utils:PASSWORD_REQUIRED;
        }

        if errorFlag {
            responseObj = {"success": false, "content": errorMsg.toJson()};
        } else {
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = ${user.email}`);
            if result is DBUser {
                boolean isPasswordValid = password:verifyHmac(user.password, result.password);
                if isPasswordValid {
                    UserDTO UserDTO = {
                        first_name: result.first_name,
                        last_name: result.last_name,
                        email: result.email,
                        userType: "user",
                        expiryTime: time:expierTimeStamp()
                    };
                    string token = check jwt:generateJWT(UserDTO.toJsonString());
                    responseObj = {"success": true, "content": "Successfully Signed In", "token": token};
                } else {
                    responseObj = {"success": false, "content": "Invalid password"};
                }
            } else {
                responseObj = {"success": false, "content": "User not found"};
            }
        }

        response.setJsonPayload(responseObj);
        return response;
    }

    resource function post admin/login(@http:Payload LoginUser user) returns http:Response|http:Unauthorized|error {
        http:Response response = new;
        json responseObj = {};
        map<string> errorMsg = {};
        boolean errorFlag = false;

        if user.email is "" {
            errorFlag = true;
            errorMsg["email"] = utils:EMAIL_REQUIRED;
        } else if !regex:matches(user.email, utils:EMAIL_REGEX) {
            errorFlag = true;
            errorMsg["email"] = utils:EMAIL_INVALID_FORMAT;
        }

        if user.password is "" {
            errorFlag = true;
            errorMsg["password"] = utils:PASSWORD_REQUIRED;
        }

        if errorFlag {
            responseObj = {"success": false, "content": errorMsg.toJson()};
        } else {
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM admin WHERE email = ${user.email}`);
            if result is DBUser {
                boolean isPasswordValid = password:verifyHmac(user.password, result.password);
                if isPasswordValid {
                    UserDTO UserDTO = {
                        first_name: result.first_name,
                        last_name: result.last_name,
                        email: result.email,
                        userType: "admin",
                        expiryTime: time:expierTimeStamp()
                    };
                    string token = check jwt:generateJWT(UserDTO.toJsonString());
                    responseObj = {"success": true, "content": "Successfully Signed In", "token": token};
                } else {
                    responseObj = {"success": false, "content": "Invalid password"};
                }
            } else {
                responseObj = {"success": false, "content": "User not found"};
            }
        }

        response.setJsonPayload(responseObj);
        return response;
    }
}

