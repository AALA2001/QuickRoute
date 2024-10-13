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

    resource function get plan/allPlans/[string BALUSERTOKEN]() returns json|error|http:Response {
        http:Response backendResponse = new ();
        json responseResult = {};
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = check self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                return response(false, "user not found");
            } else if result is sql:Error {
                return response(false, "Query did not retrieve data");
            } else {
                if result is DBUser {
                    stream<UserHasPlans, sql:Error?> user_has_plans_stream = self.connection->query(`SELECT trip_plan.id AS plan_id,trip_plan.plan_name,user_id FROM user_has_trip_plans INNER JOIN trip_plan ON user_has_trip_plans.trip_plan_id = trip_plan.id  WHERE user_id = ${result.id}`);
                    UserHasPlans[] QuickRouteUserHasPlans = [];
                    check from UserHasPlans user_has_plan in user_has_plans_stream
                        do {
                            QuickRouteUserHasPlans.push(user_has_plan);
                        };
                    check user_has_plans_stream.close();
                    responseResult = {success: true, plans: QuickRouteUserHasPlans.toJson()};
                }
            }
        } else {
            return response(false, "Token has expired");
        }
        backendResponse.setJsonPayload(responseResult);
        return backendResponse;
    }

    resource function put plan/rename/[string BALUSERTOKEN](@http:Payload PlanRename newPlanName) returns json|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = check self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                return response(false, "user not found");
            } else if result is sql:Error {
                return response(false, "Query did not retrieve data");
            } else {
                if result is DBUser {
                    UserHasPlans|sql:Error tripPlanResult = check self.connection->queryRow(`SELECT trip_plan.id AS plan_id,trip_plan.plan_name,user_id FROM user_has_trip_plans INNER JOIN trip_plan ON user_has_trip_plans.trip_plan_id = trip_plan.id  WHERE user_id = ${result.id} AND trip_plan_id = ${newPlanName.plan_id}`);
                    if tripPlanResult is sql:NoRowsError {
                        return response(false, "Plan not found");
                    } else if tripPlanResult is sql:Error {
                        return response(false, "Query did not retrieve data");
                    } else {
                        if tripPlanResult is UserHasPlans {
                            _ = check self.connection->execute(`UPDATE trip_plan SET plan_name = (${newPlanName.new_name}) WHERE id = ${newPlanName.plan_id}`);
                            return response(true, "Plan name updated successfully");
                        }
                    }
                }
            }
        } else {
            return response(false, "Token has expired");
        }
    }

    resource function post site/review/[string BALUSERTOKEN](@http:Payload siteReview SiteReview) returns json|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = check self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                return response(false, "user not found");
            } else {
                if result is DBUser {
                    _ = check self.connection->execute(`INSERT INTO reviews (review, user_id) VALUES (${SiteReview.review},${result.id})`);
                    return response(true, "Review added successfully");
                } else {
                    return response(false, "Query did not retrieve data");
                }
            }
        } else {
            return response(false, "Token has expired");
        }
    }

    resource function get user/wishlist/[string BALUSERTOKEN](int destinations_id) returns json|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = check self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                return response(false, "user not found");
            } else {
                DBDestination|sql:Error destination = check self.connection->queryRow(`SELECT * FROM destination_location WHERE id = (${destinations_id})`);
                if destination is sql:NoRowsError {
                    return response(false, "Destination not found");
                } else {
                    if destination is DBDestination {
                        if result is DBUser {
                            _ = check self.connection->execute(`INSERT INTO wishlist (user_id,destination_location_id) VALUES (${destinations_id},${destination.id})`);
                            return response(true, "Destination added to wishlist successfully");
                        } else {
                            return response(false, "Query did not retrieve data");
                        }
                    } else {
                        return response(false, "Query did not retrieve data");
                    }
                }
            }
        } else {
            return response(false, "Token has expired");
        }
    }
}

function response(boolean status, string message) returns json {
    return {"success": status, "content": message};
}
