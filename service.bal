import QuickRoute.db;
import QuickRoute.password;

import ballerina/http;
import ballerina/random;
import ballerina/regex;
import ballerina/sql;
import ballerinax/mysql;



listener http:Listener authEP = new (9091);

service /auth on authEP {
    private final mysql:Client connection;

    function init() returns error? {
        self.connection = db:getConnection();
    }

    resource function post register(@http:Payload RequestUser user) returns http:Response|http:Unauthorized|error {
        http:Response response = new;
        json responseObj = {};
        map<string> errorMsg = {};

        boolean errorFlag = false;

        final string emailRgex = "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$";
        final string passwordRegex = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$";

        if user.first_name is "" {
            errorFlag = true;
            errorMsg["first_name"] = "First name required";
        } else if user.first_name.length() > 45 {
            errorFlag = true;
            errorMsg["first_name"] = "First Name should not exceed 4";
        }

        if user.last_name is "" {
            errorFlag = true;
            errorMsg["last_name"] = "Last name required";
        } else if user.last_name.length() > 45 {
            errorFlag = true;
            errorMsg["last_name"] = "Last Name should not exceed 4";
        }

        if user.email is "" {
            errorFlag = true;
            errorMsg["email"] = "Email required";
        } else if user.email.length() > 200 {
            errorFlag = true;
            errorMsg["email"] = "Email should not exceed 200";
        } else if !regex:matches(user.email, emailRgex) {
            errorFlag = true;
            errorMsg["email"] = "Invalid email format";
        }

        if user.password is "" {
            errorFlag = true;
            errorMsg["password"] = "Password required";
        } else if !regex:matches(user.password, passwordRegex) {
            errorFlag = true;
            errorMsg["password"] = "Password should be minimum 8 characters in length, shouldcontain at least one uppercase letter, one lowercase letter, at  least one digit and at least one special character";
        }

        if errorFlag {
            responseObj = {"success": false, "content": errorMsg.toJson()};
        } else {
            string hashedPassword = password:generateHmac(user.password);
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = ${user.email}`);
            if result is sql:NoRowsError {
                _ = check self.connection->execute(`INSERT INTO user (first_name,last_name,email,password)  VALUES (${user.first_name}, ${user.last_name}, ${user.email}, ${hashedPassword});`);
                float sessionID = random:createDecimal();
                http:Cookie sessionCookie = new ("BALSESSIONID", sessionID.toString(), path = "/");
                http:Cookie userCookie = new ("BALUSER", user.toString(), path = "/");

                response.addCookie(sessionCookie);
                response.addCookie(userCookie);
                responseObj = {"success": true, "content": "Successfully Registered"};
            } else {
                responseObj = {"success": false, "content": "User already exists"};
            }
        }

        response.setJsonPayload(responseObj);
        return response;
    }
}
