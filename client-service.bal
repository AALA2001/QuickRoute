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
        http:Response backendResponse = new;
        if planName == "" {
            backendResponse.setJsonPayload({success: false, message: "plan name is required"});
            backendResponse.statusCode = http:STATUS_BAD_REQUEST;
            return backendResponse;
        } else if (planName.length() > 50) {
            backendResponse.setJsonPayload({success: false, message: "plan name is too long"});
            backendResponse.statusCode = http:STATUS_BAD_REQUEST;
            return backendResponse;
        } else {
            json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
            UserDTO payload = check jsondata:parseString(decodeJWT.toString());
            if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
                sql:ExecutionResult executionResult = check self.connection->execute(`INSERT INTO  trip_plan (plan_name) VALUES (${planName})`);
                int lastInsertId = <int>executionResult.lastInsertId;
                DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
                if result is sql:NoRowsError {
                    backendResponse.setJsonPayload({success: false, message: "user not found"});
                    backendResponse.statusCode = http:STATUS_NOT_FOUND;
                    return backendResponse;
                } else if result is sql:Error {
                    backendResponse.setJsonPayload({success: false, message: "database error"});
                    backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    return backendResponse;
                } else {
                    if result is DBUser {
                        _ = check self.connection->execute(`INSERT INTO  user_has_trip_plans (trip_plan_id,user_id) VALUES (${lastInsertId},${result.id})`);
                    }
                }
                backendResponse.setJsonPayload({success: true, message: "plan created"});
                backendResponse.statusCode = http:STATUS_CREATED;
                return backendResponse;
            } else {
                backendResponse.setJsonPayload({success: false, message: "token expired"});
                backendResponse.statusCode = http:STATUS_UNAUTHORIZED;
                return backendResponse;
            }
        }
    }

    resource function get plan/allPlans/[string BALUSERTOKEN]() returns json|error|http:Response {
        http:Response backendResponse = new;
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                backendResponse.setJsonPayload({success: false, message: "user not found"});
                backendResponse.statusCode = http:STATUS_NOT_FOUND;
                return backendResponse;
            } else if result is sql:Error {
                backendResponse.setJsonPayload({success: false, message: "database error"});
                backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                return backendResponse;
            } else {
                if result is DBUser {
                    stream<UserHasPlans, sql:Error?> user_has_plans_stream = self.connection->query(`SELECT trip_plan.id AS plan_id,trip_plan.plan_name,user_id FROM user_has_trip_plans INNER JOIN trip_plan ON user_has_trip_plans.trip_plan_id = trip_plan.id  WHERE user_id = ${result.id}`);
                    UserHasPlans[] QuickRouteUserHasPlans = [];
                    check from UserHasPlans user_has_plan in user_has_plans_stream
                        do {
                            QuickRouteUserHasPlans.push(user_has_plan);
                        };
                    check user_has_plans_stream.close();
                    if (QuickRouteUserHasPlans.length() == 0) {
                        backendResponse.setJsonPayload({success: false, message: "no plans found"});
                        backendResponse.statusCode = http:STATUS_NOT_FOUND;
                        return backendResponse;
                    } else {
                        backendResponse.setJsonPayload({success: true, plans: QuickRouteUserHasPlans.toJson()});
                        backendResponse.statusCode = http:STATUS_OK;
                        return backendResponse;
                    }
                }
            }
        } else {
            backendResponse.setJsonPayload({success: false, message: "token expired"});
            backendResponse.statusCode = http:STATUS_UNAUTHORIZED;
            return backendResponse;
        }
    }

    resource function put plan/rename/[string BALUSERTOKEN](@http:Payload PlanRename newPlanName) returns http:Response|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        http:Response backendResponse = new;
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                backendResponse.setJsonPayload({success: false, message: "user not found"});
                backendResponse.statusCode = http:STATUS_NOT_FOUND;
                return backendResponse;
            } else if result is sql:Error {
                backendResponse.setJsonPayload({success: false, message: "database error"});
                backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                return backendResponse;
            } else {
                if result is DBUser {
                    UserHasPlans|sql:Error tripPlanResult = self.connection->queryRow(`SELECT trip_plan.id AS plan_id,trip_plan.plan_name,user_id FROM user_has_trip_plans INNER JOIN trip_plan ON user_has_trip_plans.trip_plan_id = trip_plan.id  WHERE user_id = ${result.id} AND trip_plan_id = ${newPlanName.plan_id}`);
                    if tripPlanResult is sql:NoRowsError {
                        backendResponse.setJsonPayload({success: false, message: "plan not found"});
                        backendResponse.statusCode = http:STATUS_NOT_FOUND;
                        return backendResponse;
                    } else if tripPlanResult is sql:Error {
                        backendResponse.setJsonPayload({success: false, message: "database error"});
                        backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        return backendResponse;
                    } else {
                        if tripPlanResult is UserHasPlans {
                            _ = check self.connection->execute(`UPDATE trip_plan SET plan_name = (${newPlanName.new_name}) WHERE id = ${newPlanName.plan_id}`);
                            backendResponse.setJsonPayload({success: true, message: "plan renamed"});
                            backendResponse.statusCode = http:STATUS_OK;
                            return backendResponse;
                        }
                    }
                }
            }
        } else {
            backendResponse.setJsonPayload({success: false, message: "token expired"});
            backendResponse.statusCode = http:STATUS_UNAUTHORIZED;
            return backendResponse;
        }
    }

    resource function post site/review/[string BALUSERTOKEN](@http:Payload siteReview SiteReview) returns http:Response|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        http:Response backendResponse = new;
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                backendResponse.setJsonPayload({success: false, message: "user not found"});
                backendResponse.statusCode = http:STATUS_NOT_FOUND;
                return backendResponse;
            } else {
                if result is DBUser {
                    _ = check self.connection->execute(`INSERT INTO reviews (review, user_id) VALUES (${SiteReview.review},${result.id})`);
                    backendResponse.setJsonPayload({success: true, message: "review added"});
                    backendResponse.statusCode = http:STATUS_OK;
                    return backendResponse;
                } else {
                    backendResponse.setJsonPayload({success: false, message: "database error"});
                    backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    return backendResponse;
                }
            }
        } else {
            backendResponse.setJsonPayload({success: false, message: "token expired"});
            backendResponse.statusCode = http:STATUS_UNAUTHORIZED;
            return backendResponse;
        }
    }

    resource function get user/wishlist/add/[string BALUSERTOKEN](int destinations_id) returns http:Response|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        http:Response backendResponse = new;
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                backendResponse.setJsonPayload({success: false, message: "user not found"});
                backendResponse.statusCode = http:STATUS_NOT_FOUND;
                return backendResponse;
            } else {
                DBLocation|sql:Error destination = self.connection->queryRow(`SELECT * FROM destination_location WHERE id = (${destinations_id})`);
                if destination is sql:NoRowsError {
                    backendResponse.setJsonPayload({success: false, message: "destination not found"});
                    backendResponse.statusCode = http:STATUS_NOT_FOUND;
                    return backendResponse;
                } else {
                    if destination is DBLocation {
                        if result is DBUser {
                            _ = check self.connection->execute(`INSERT INTO wishlist (user_id,destination_location_id) VALUES (${result.id},${destination.id})`);
                            backendResponse.setJsonPayload({success: true, message: "destination added to wishlist"});
                            backendResponse.statusCode = http:STATUS_OK;
                            return backendResponse;
                        } else {
                            backendResponse.setJsonPayload({success: false, message: "database error"});
                            backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                            return backendResponse;
                        }
                    } else {
                        backendResponse.setJsonPayload({success: false, message: "database error"});
                        backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        return backendResponse;
                    }
                }
            }
        } else {
            backendResponse.setJsonPayload({success: false, message: "token expired"});
            backendResponse.statusCode = http:STATUS_UNAUTHORIZED;
            return backendResponse;
        }
    }

    resource function get user/wishlist/[string BALUSERTOKEN]() returns http:Response|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        http:Response backendResponse = new;
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                backendResponse.setJsonPayload({success: false, message: "user not found"});
                backendResponse.statusCode = http:STATUS_NOT_FOUND;
                return backendResponse;
            } else if result is sql:Error {
                backendResponse.setJsonPayload({success: false, message: "database error"});
                backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                return backendResponse;
            } else {
                stream<UserWishlist, sql:Error?> user_wishlist_strem = self.connection->query(`SELECT destination_location.id AS destinations_id,destination_location.title AS destination_location_title,destinations.title AS destination_title,country.name AS country_name,ROUND(AVG(ratings.rating_count),1) AS average_rating,COUNT(ratings.rating_count) AS total_ratings,destination_location.image AS image,destination_location.overview FROM wishlist INNER JOIN destination_location ON destination_location.id = wishlist.destination_location_id INNER JOIN tour_type ON destination_location.tour_type_id = tour_type.id INNER JOIN destinations ON destinations.id = destination_location.destinations_id INNER JOIN country ON destinations.country_id = country.id LEFT JOIN ratings ON destination_location.id = ratings.destination_location_id WHERE wishlist.user_id = ${result.id} GROUP BY destination_location.id, destination_location.title, country.name`);
                UserWishlist[] userWishlist = [];
                check from UserWishlist user_wishlist in user_wishlist_strem
                    do {
                        userWishlist.push(user_wishlist);
                    };
                backendResponse.setJsonPayload({success: true, wishlist: userWishlist.toJson()});
                backendResponse.statusCode = http:STATUS_OK;
                return backendResponse;
            }
        } else {
            backendResponse.setJsonPayload({success: false, message: "token expired"});
            backendResponse.statusCode = http:STATUS_UNAUTHORIZED;
            return backendResponse;
        }
    }

    resource function delete user/wishlist/removeDestination/[string BALUSERTOKEN](@http:Payload removeWishList RemoveDestination) returns http:Response|error {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        http:Response backendResponse = new;
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = (${payload.email})`);
            if result is sql:NoRowsError {
                backendResponse.setJsonPayload({success: false, message: "user not found"});
                backendResponse.statusCode = http:STATUS_NOT_FOUND;
                return backendResponse;
            } else {
                if result is DBUser {
                    wishlist|sql:Error wishlistRow = self.connection->queryRow(`SELECT * FROM wishlist WHERE user_id = (${result.id}) AND destination_location_id = ${RemoveDestination.destinations_id}`);
                    if wishlistRow is sql:NoRowsError {
                        backendResponse.setJsonPayload({success: false, message: "destination not found in wishlist"});
                        backendResponse.statusCode = http:STATUS_NOT_FOUND;
                        return backendResponse;
                    } else if wishlistRow is sql:Error {
                        backendResponse.setJsonPayload({success: false, message: "database error"});
                        backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        return backendResponse;
                    } else {
                        _ = check self.connection->execute(`DELETE FROM wishlist WHERE user_id = ${result.id} AND destination_location_id = ${RemoveDestination.destinations_id}`);
                        backendResponse.setJsonPayload({success: true, message: "destination removed from wishlist"});
                        backendResponse.statusCode = http:STATUS_OK;
                        return backendResponse;
                    }
                } else {
                    backendResponse.setJsonPayload({success: false, message: "database error"});
                    backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    return backendResponse;
                }
            }
        } else {
            backendResponse.setJsonPayload({success: false, message: "token expired"});
            backendResponse.statusCode = http:STATUS_UNAUTHORIZED;
            return backendResponse;
        }

    }

    resource function get plan/userPlan/addDestination/[string BALUSERTOKEN](int plan_id, int destination_id) returns error|http:Response {
        json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
        UserDTO payload = check jsondata:parseString(decodeJWT.toString());
        http:Response backendResponse = new;
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM user WHERE email = ${payload.email}`);
            if result is sql:NoRowsError {
                backendResponse.setJsonPayload({success: false, message: "user not found"});
                backendResponse.statusCode = http:STATUS_NOT_FOUND;
                return backendResponse;
            } else {
                if result is DBUser {
                    DBLocation|sql:Error destination = self.connection->queryRow(`SELECT * FROM destination_location WHERE id = ${destination_id}`);
                    if destination is sql:NoRowsError {
                        backendResponse.setJsonPayload({success: false, message: "destination not found"});
                        backendResponse.statusCode = http:STATUS_NOT_FOUND;
                        return backendResponse;
                    } else if destination is sql:Error {
                        backendResponse.setJsonPayload({success: false, message: "database error"});
                        backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                        return backendResponse;
                    } else {
                        DBPlan|sql:Error plan = self.connection->queryRow(`SELECT * FROM trip_plan  WHERE id = ${plan_id}`);
                        if plan is sql:NoRowsError {
                            backendResponse.setJsonPayload({success: false, message: "plan not found"});
                            backendResponse.statusCode = http:STATUS_NOT_FOUND;
                            return backendResponse;
                        } else if plan is sql:Error {
                            backendResponse.setJsonPayload({success: false, message: "database error"});
                            backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                            return backendResponse;
                        } else {
                            plan_has_des|sql:Error queryRow = self.connection->queryRow(`SELECT * FROM plan_has_des WHERE destination_location_id = ${destination_id} AND trip_plan_id = ${plan_id}`);
                            if queryRow is sql:NoRowsError {
                                _ = check self.connection->execute(`INSERT INTO plan_has_des (trip_plan_id,destination_location_id) VALUES  (${plan_id},${destination_id})`);
                                backendResponse.setJsonPayload({success: true, message: "destination added"});
                                backendResponse.statusCode = http:STATUS_OK;
                                return backendResponse;
                            } else if queryRow is sql:Error {
                                backendResponse.setJsonPayload({success: false, message: "database error"});
                                backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                                return backendResponse;
                            } else {
                                backendResponse.setJsonPayload({success: false, message: "destination already added"});
                                backendResponse.statusCode = http:STATUS_CONFLICT;
                                return backendResponse;
                            }
                        }
                    }
                } else {
                    backendResponse.setJsonPayload({success: false, message: "database error"});
                    backendResponse.statusCode = http:STATUS_INTERNAL_SERVER_ERROR;
                    return backendResponse;
                }
            }
        } else {
            backendResponse.setJsonPayload({success: false, message: "token expired"});
            backendResponse.statusCode = http:STATUS_UNAUTHORIZED;
            return backendResponse;
        }
    }

    resource function get destinationLocation() returns http:Response|error {
        http:Response backendResponse = new;
        stream<DBLocationDetails, sql:Error?> dbDestination_stream = self.connection->query(`SELECT destination_location.id AS location_id, destination_location.title AS title, destination_location.image AS image,destination_location.overview AS overview, tour_type.type AS tour_type,destinations.title AS destination_title, country.name AS country_name FROM destination_location INNER JOIN destinations ON destinations.id = destination_location.destinations_id INNER JOIN country ON destinations.country_id = country.id INNER JOIN tour_type ON destination_location.tour_type_id = tour_type.id`);
        DBLocationDetails[] QuickRouteDestination = [];
        check from DBLocationDetails dbDestination in dbDestination_stream
            do {
                QuickRouteDestination.push(dbDestination);
            };
        check dbDestination_stream.close();
        backendResponse.setJsonPayload(QuickRouteDestination);
        backendResponse.statusCode = http:STATUS_OK;
        return backendResponse;
    }

    resource function get homepage() returns error|http:Response {
        http:Response backendResponse = new;
        stream<DBLocationDetailsWithReview, sql:Error?> dbDestination_stream = self.connection->query(`SELECT destination_location.id AS destination_id,destination_location.title,destination_location.overview ,country.name AS country_name,tour_type.type AS tour_type,COUNT(ratings.id) AS total_reviews,destination_location.image , ROUND(AVG(ratings.rating_count),1)AS average_rating , destinations.title AS destination_title FROM ratings INNER JOIN destination_location ON ratings.destination_location_id = destination_location.id INNER JOIN destinations ON destination_location.destinations_id = destinations.id INNER JOIN country ON destinations.country_id = country.id INNER JOIN tour_type ON destination_location.tour_type_id = tour_type.id GROUP BY destination_location.id, destination_location.title, destination_location.overview, country.name, tour_type.type ORDER BY total_reviews DESC LIMIT 10`);
        DBLocationDetailsWithReview[] QuickRouteDestination = [];
        check from DBLocationDetailsWithReview dbDestination in dbDestination_stream
            do {
                QuickRouteDestination.push(dbDestination);
            };
        check dbDestination_stream.close();
        stream<userAddedSiteReview, sql:Error?> userAddedReview = self.connection->query(`SELECT first_name,last_name,email,review ,(SELECT COUNT(reviews.id) FROM reviews) AS total_review_count FROM  reviews INNER JOIN user ON reviews.user_id = user.id `);
        userAddedSiteReview[] userAddedReviews = [];
        check from userAddedSiteReview userReview in userAddedReview
            do {
                userAddedReviews.push(userReview);
            };
        check userAddedReview.close();
        stream<DestinationsWithLocationCount, sql:Error?> destination_with_location_count_stream = self.connection->query(`SELECT d.id AS id, d.title AS destination_title,d.image AS destination_image,COUNT(dl.id) AS location_count FROM destinations d INNER JOIN destination_location dl ON d.id = dl.destinations_id GROUP BY d.id, d.title, d.image ORDER BY location_count DESC LIMIT 8`);
        DestinationsWithLocationCount[] destinations_with_location_count = [];
        check from DestinationsWithLocationCount destination in destination_with_location_count_stream
            do {
                destinations_with_location_count.push(destination);
            };
        check destination_with_location_count_stream.close();
        stream<userOffers, sql:Error?> user_offers_stream = self.connection->query(`SELECT offers.from_Date,offers.to_Date,offers.title AS offer_title,offers.image AS offer_image, destination_location.title AS destinations_name , country.name AS country FROM offers INNER JOIN destination_location ON destination_location.id = offers.destination_location_id INNER JOIN destinations ON destinations.id = destination_location.destinations_id INNER JOIN country ON country.id = destinations.country_id WHERE offers.to_Date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 2 DAY) LIMIT 3`);
        userOffers[] offers = [];
        check from userOffers offer in user_offers_stream
            do {
                offers.push(offer);
            };
        int|sql:Error destination_count = check self.connection->queryRow(`SELECT COUNT(*) FROM destinations`);
        int|sql:Error users_count = check self.connection->queryRow(`SELECT COUNT(*) FROM user`);
        int|sql:Error destination_location_count = check self.connection->queryRow(`SELECT COUNT(*) FROM destination_location`);
        json bannerData = {
            destination_count: check destination_count,
            users_count: check users_count,
            destination_location_count: check destination_location_count
        };
        backendResponse.setJsonPayload({
            destinationLocation: QuickRouteDestination.toJson(),
            userSiteReviews: userAddedReviews.toJson(),
            destinations_with_location_count: destinations_with_location_count.toJson(),
            offers: offers.toJson(),
            bannerData: bannerData
        });
        backendResponse.statusCode = http:STATUS_OK;
        return backendResponse;
    }

}

