import QuickRoute.db;
import QuickRoute.jwt;
import QuickRoute.time;
import QuickRoute.utils;

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
                return utils:response(false, "user not found");
            } else if result is sql:Error {
                return utils:response(false, "Query did not retrieve data");
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
            return utils:response(false, "Token has expired");
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
                return utils:response(false, "user not found");
            } else if result is sql:Error {
                return utils:response(false, "Query did not retrieve data");
            } else {
                if result is DBUser {
                    UserHasPlans|sql:Error tripPlanResult = check self.connection->queryRow(`SELECT trip_plan.id AS plan_id,trip_plan.plan_name,user_id FROM user_has_trip_plans INNER JOIN trip_plan ON user_has_trip_plans.trip_plan_id = trip_plan.id  WHERE user_id = ${result.id} AND trip_plan_id = ${newPlanName.plan_id}`);
                    if tripPlanResult is sql:NoRowsError {
                        return utils:response(false, "Plan not found");
                    } else if tripPlanResult is sql:Error {
                        return utils:response(false, "Query did not retrieve data");
                    } else {
                        if tripPlanResult is UserHasPlans {
                            _ = check self.connection->execute(`UPDATE trip_plan SET plan_name = (${newPlanName.new_name}) WHERE id = ${newPlanName.plan_id}`);
                            return utils:response(true, "Plan name updated successfully");
                        }
                    }
                }
            }
        } else {
            return utils:response(false, "Token has expired");
        }
    }

    resource function post site/review/[string BALUSERTOKEN](@http:Payload siteReview SiteReview) returns json|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = check self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                return utils:response(false, "user not found");
            } else {
                if result is DBUser {
                    _ = check self.connection->execute(`INSERT INTO reviews (review, user_id) VALUES (${SiteReview.review},${result.id})`);
                    return utils:response(true, "Review added successfully");
                } else {
                    return utils:response(false, "Query did not retrieve data");
                }
            }
        } else {
            return utils:response(false, "Token has expired");
        }
    }

    resource function get user/wishlist/[string BALUSERTOKEN](int destinations_id) returns json|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = check self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                return utils:response(false, "user not found");
            } else {
                DBDestination|sql:Error destination = check self.connection->queryRow(`SELECT * FROM destination_location WHERE id = (${destinations_id})`);
                if destination is sql:NoRowsError {
                    return utils:response(false, "Destination not found");
                } else {
                    if destination is DBDestination {
                        if result is DBUser {
                            _ = check self.connection->execute(`INSERT INTO wishlist (user_id,destination_location_id) VALUES (${result.id},${destination.id})`);
                            return utils:response(true, "Destination added to wishlist successfully");
                        } else {
                            return utils:response(false, "Query did not retrieve data");
                        }
                    } else {
                        return utils:response(false, "Query did not retrieve data");
                    }
                }
            }
        } else {
            return utils:response(false, "Token has expired");
        }
    }

    resource function delete user/wishlist/removeDestination/[string BALUSERTOKEN](@http:Payload removeWishList RemoveDestination) returns json|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = check self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                return utils:response(false, "user not found");
            } else {
                if result is DBUser {
                    wishlist|sql:Error wishlistRow = check self.connection->queryRow(`SELECT * FROM wishlist WHERE user_id = (${result.id}) AND destination_location_id = ${RemoveDestination.destinations_id}`);
                    if wishlistRow is sql:NoRowsError {
                        return utils:response(false, "Destination not found in wishlist");
                    } else if wishlistRow is wishlist {
                        _ = check self.connection->execute(`DELETE FROM wishlist WHERE user_id = ${result.id} AND destination_location_id = ${RemoveDestination.destinations_id}`);
                        return utils:response(true, "Destination removed from wishlist successfully");
                    }
                } else {
                    return utils:response(false, "Query did not retrieve data");
                }
            }
        } else {
            return utils:response(false, "Token has expired");
        }
    }

    resource function get plan/userPlan/addDestination/[string BALUSERTOKEN](int plan_id, int destination_id) returns json|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = check self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                return utils:response(false, "user not found");
            } else {
                if result is DBUser {
                    DBLocation|sql:Error destination = check self.connection->queryRow(`SELECT * FROM destination_location WHERE id = (${destination_id})`);
                    if destination is sql:NoRowsError {
                        return utils:response(false, "Destination not found");
                    } else if destination is DBLocation {
                        DBPlan|sql:Error plan = check self.connection->queryRow(`SELECT * FROM trip_plan  WHERE id = (${plan_id})`);
                        if plan is sql:NoRowsError {
                            return utils:response(false, "Plan not found");
                        } else if plan is DBPlan {
                            sql:ExecutionResult|sql:Error users_trip_des = self.connection->execute(`INSERT INTO users_trip_des (destination_location_id) VALUES ${destination_id}`);
                            if users_trip_des is sql:Error {
                                return utils:response(false, "Failed to add destination to plan");
                                } else {
                                    int users_trip_des_id =<int> users_trip_des.lastInsertId;
                                    _ = check self.connection->execute(`INSERT INTO plan_has_des (trip_plan_id,users_trip_des_id) VALUES  (${plan_id},${users_trip_des_id})`);
                                    return utils:response(true, "Destination added to plan successfully");
                                }
                        }
                    }
                }
            }
        } else {
            return utils:response(false, "Token has expired");
        }
    }
}

