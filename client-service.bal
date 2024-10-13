import QuickRoute.db;
import QuickRoute.jwt;
import QuickRoute.time;

import ballerina/data.jsondata;
import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

listener http:Listener clientSideEP = new (9093);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE"],
        allowCredentials: true
    }
}

service /clientData on clientSideEP {

    private final mysql:Client connection;

    function init() returns error? {
        self.connection = db:getConnection();
    }

    function __deinit() returns sql:Error? {
        _ = checkpanic self.connection.close();
    }

    resource function get plan/create/[string BALUSERTOKEN](string planName) returns http:Response|error {
        http:Response backendResponse = new ();
        json responseResult = {};
        if planName == "" {
            responseResult = {success: false, message: "plan name is required"};
        } else if (planName.length() > 50) {
            responseResult = {success: false, message: "plan name is too long"};
        } else {
            json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
            UserDTO payload = check jsondata:parseString(decodeJWT.toString());
            if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
                sql:ExecutionResult executionResult = check self.connection->execute(`INSERT INTO  trip_plan (plan_name) VALUES (${planName})`);
                int lastInsertId = <int>executionResult.lastInsertId;
                DBUser|sql:Error result = check self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
                if result is sql:NoRowsError {
                    responseResult = {success: false, message: "user not found"};
                } else if result is sql:Error {
                    responseResult = {success: false, message: "Query did not retrieve data"};
                } else {
                    if result is DBUser {
                        _ = check self.connection->execute(`INSERT INTO  user_has_trip_plans (trip_plan_id,user_id) VALUES (${lastInsertId},${result.id})`);
                    }
                }
                responseResult = {success: true, message: "Plan created successfully"};
            } else {
                responseResult = {success: false, message: "Token has expired"};
            }
        }
        backendResponse.setJsonPayload(responseResult);
        return backendResponse;
    }
}

function response(boolean status, string message) returns json {
    return {"success": status, "content": message};
}
