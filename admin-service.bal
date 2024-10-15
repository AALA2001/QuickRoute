import QuickRoute.db;
import QuickRoute.filters;
import QuickRoute.img;
import QuickRoute.password;
import QuickRoute.utils;

import ballerina/http;
import ballerina/io;
import ballerina/regex;
// import ballerina/mime;
// import ballerina/regex;
import ballerina/sql;
import ballerinax/mysql;

http:ClientConfiguration clientEPConfig = {
    cookieConfig: {
        enabled: true
    }
};
listener http:Listener adminEP = new (9092);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE"],
        allowCredentials: true
    }
}

service /data on adminEP {

    private final mysql:Client connection;

    function init() returns error? {
        self.connection = db:getConnection();
    }

    function __deinit() returns sql:Error? {
        _ = checkpanic self.connection.close();
    }

    resource function get admin/getCountries/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|error|http:Response {
        http:Response response = new;
        DBCountry[] countries = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        stream<DBCountry, sql:Error?> countryStream = self.connection->query(`SELECT * FROM country`);
        sql:Error? streamError = countryStream.forEach(function(DBCountry country) {
            countries.push(country);
        });
        io:println(streamError);
        if streamError is sql:Error {
            check countryStream.close();
            return utils:setErrorResponse(response, "Error in retrieving countries");
        }
        response.setJsonPayload({
            "success": true,
            "content": countries.toJson()
        });
        return response;
    }

    resource function post admin/addDestination/[string BALUSERTOKEN](http:Request req) returns http:Response|error? {
        http:Response res = new;
        map<any> formData = {};

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        if !utils:validateContentType(req.getContentType()) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:INVALID_CONTENT_TYPE);
        }

        map<any>|error multipartFormData = utils:parseMultipartFormData(req.getBodyParts(), formData);
        if multipartFormData is error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_MULTIPART_REQUEST);
        }

        if !formData.hasKey("country_id") || !formData.hasKey("title") || !formData.hasKey("description") || !formData.hasKey("file") {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:REQUIRED_FIELDS_MISSING);
        }

        string countryId = <string>formData["country_id"];
        string title = <string>formData["title"];
        string description = <string>formData["description"];

        if int:fromString(countryId) !is int {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_COUNTRY_ID);
        }

        DBCountry|sql:Error countryResult = self.connection->queryRow(`SELECT * FROM country WHERE id=${countryId}`);
        if countryResult is sql:NoRowsError {
            return utils:returnResponseWithStatusCode(res, http:STATUS_NOT_FOUND, utils:COUNTRY_NOT_FOUND);
        } else if countryResult is sql:Error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_FETCHING_COUNTRY);
        }

        DBDestination|sql:Error destinationResult = self.connection->queryRow(`SELECT * FROM destinations WHERE title = ${title} AND country_id=${countryId}`);
        if destinationResult is sql:NoRowsError {
            if formData["file"] is byte[] {
                string|error|io:Error? uploadImagee = img:uploadImage(<byte[]>formData["file"], "destinations/", title);
                if uploadImagee is io:Error || uploadImagee is error {
                    return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_UPLOADING_IMAGE);
                }
                _ = check self.connection->execute(`INSERT INTO destinations (title, country_id, image, description) VALUES (${title}, ${countryId}, ${uploadImagee}, ${description})`);
                return utils:returnResponseWithStatusCode(res, http:STATUS_CREATED, utils:DESTINATION_SUCCESS, true);
            }
        } else if destinationResult is sql:Error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_FETCHING_DESTINATION);
        } else {
            return utils:returnResponseWithStatusCode(res, http:STATUS_CONFLICT, utils:DESTINATION_ALREADY_EXISTS);
        }
        return res;
    }

    resource function post admin/addLocation/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
        http:Response res = new;
        map<any> formData = {};

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        if !utils:validateContentType(req.getContentType()) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:INVALID_CONTENT_TYPE);
        }

        map<any>|error multipartFormData = utils:parseMultipartFormData(req.getBodyParts(), formData);
        if multipartFormData is error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_MULTIPART_REQUEST);
        }

        if !formData.hasKey("destinationId") || !formData.hasKey("tourTypeId") || !formData.hasKey("title") || !formData.hasKey("overview") || !formData.hasKey("file") {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:REQUIRED_FIELDS_MISSING);
        }

        string destinationId = <string>formData["destinationId"];
        string tourTypeId = <string>formData["tourTypeId"];
        string title = <string>formData["title"];
        string overview = <string>formData["overview"];

        if int:fromString(destinationId) !is int || int:fromString(tourTypeId) !is int {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_DESTINATION_TOUTYPE_ID);
        }

        DBDestination|sql:Error desResult = self.connection->queryRow(`SELECT * FROM destinations WHERE id=${destinationId}`);
        DBTourType|sql:Error tourResult = self.connection->queryRow(`SELECT * FROM tour_type WHERE id=${tourTypeId}`);
        if desResult is sql:NoRowsError {
            return utils:returnResponseWithStatusCode(res, http:STATUS_NOT_FOUND, utils:DESTINATION_NOT_FOUND);
        } else if desResult is sql:Error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_FETCHING_DESTINATION);
        }
        if tourResult is sql:NoRowsError {
            return utils:returnResponseWithStatusCode(res, http:STATUS_NOT_FOUND, utils:TOURTYPE_NOT_FOUND);
        } else if tourResult is sql:Error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_FETCHING_TOURTYPE);
        }

        DBLocation|sql:Error locationResult = self.connection->queryRow(`SELECT * FROM  destination_location WHERE title=${title} AND destinations_id=${destinationId}`);
        if locationResult is sql:NoRowsError {
            string|error|io:Error? uploadedImagePath = img:uploadImage(<byte[]>formData["file"], "locations/", title);
            if uploadedImagePath is io:Error || uploadedImagePath is error {
                return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:IMAGE_UPLOAD);
            }
            _ = check self.connection->execute(`INSERT INTO destination_location (title,image,overview,tour_type_id,destinations_id) VALUES (${title},${uploadedImagePath},${overview},${tourTypeId},${destinationId})`);
            return utils:returnResponseWithStatusCode(res, http:STATUS_CREATED, utils:LOCATION_SUCCESS, true);
        } else if locationResult is sql:Error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_FETCHING_DESTINATION_LOCATION);
        } else {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:DESTINATION_LOCATION_ALREADY_EXISTS);
        }
    }

    resource function post admin/addOffer/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
        http:Response res = new;
        map<any> formData = {};

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        if !utils:validateContentType(req.getContentType()) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:INVALID_CONTENT_TYPE);
        }

        map<any>|error multipartFormData = utils:parseMultipartFormData(req.getBodyParts(), formData);
        if multipartFormData is error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_MULTIPART_REQUEST);
        }

        if !formData.hasKey("destinationLocationId") || !formData.hasKey("fromDate") || !formData.hasKey("toDate") || !formData.hasKey("title") || !formData.hasKey("file") {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:REQUIRED_FIELDS_MISSING);
        }

        string destinationLocationId = <string>formData["destinationLocationId"];
        string fromDate = <string>formData["fromDate"];
        string toDate = <string>formData["toDate"];
        string title = <string>formData["title"];

        boolean isValidFromDate = regex:matches(fromDate, utils:DATETIME_REGEX);
        boolean isValidToDate = regex:matches(toDate, utils:DATETIME_REGEX);

        if int:fromString(destinationLocationId) !is int {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_DESTINATION_LOCATION_ID);
        }

        if isValidFromDate !is true && isValidToDate !is true {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_DATETIME_FROMAT);
        }

        DBLocation|sql:Error desLocResult = self.connection->queryRow(`SELECT * FROM destination_location WHERE id=${destinationLocationId}`);
        if desLocResult is sql:NoRowsError {
            return utils:returnResponseWithStatusCode(res, http:STATUS_NOT_FOUND, utils:DESTINATION_LOCATION_NOT_FOUND);
        } else if desLocResult is sql:Error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_FETCHING_DESTINATION_LOCATION);
        }

        DBOffer|sql:Error offerResult = self.connection->queryRow(`SELECT * FROM  offers WHERE title=${title} AND destination_location_id=${destinationLocationId} AND to_Date=${toDate} AND from_Date=${fromDate}`);
        if offerResult is sql:NoRowsError {
            string|error|io:Error? uploadedImagePath = img:uploadImage(<byte[]>formData["file"], "offers/", title);
            if uploadedImagePath is io:Error || uploadedImagePath is error {
                return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_UPLOADING_IMAGE);
            } else {
                _ = check self.connection->execute(`INSERT INTO offers (title,image,to_Date,from_Date,destination_location_id) VALUES (${title},${uploadedImagePath},${toDate},${fromDate},${destinationLocationId})`);
                return utils:returnResponseWithStatusCode(res, http:STATUS_CREATED, utils:OFFER_SUCCESS, true);
            }
        } else if offerResult is sql:Error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_FETCHING_OFFERS);
        } else {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:OFFER_ALREADY_EXISTS);
        }
    }

    resource function get admin/getReviews/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|http:Response|sql:Error|error {
        http:Response response = new;
        DBReview[] reviews = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        stream<DBReview, sql:Error?> reviewStream = self.connection->query(`SELECT reviews.id AS review_id, user.first_name, user.last_name, user.email, reviews.review FROM reviews INNER JOIN user ON user.id = reviews.user_id`);
        sql:Error? streamError = reviewStream.forEach(function(DBReview review) {
            reviews.push(review);
        });
        if streamError is sql:Error {
            check reviewStream.close();
            return utils:setErrorResponse(response, "Error in retrieving reviews");
        }
        response.setJsonPayload({
            "success": true,
            "content": reviews.toJson()
        });
        return response;
    }

    resource function get admin/getOffers/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|error|http:Response {
        http:Response response = new;
        DBOfferDetals[] offers = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        stream<DBOfferDetals, sql:Error?> offersStream = self.connection->query(`SELECT offers.id AS offer_id, offers.from_Date, offers.to_Date, offers.title, offers.image, destination_location.title AS location_title, tour_type.type AS tour_type, destinations.title AS destination_title, country.name AS country_name FROM offers INNER JOIN destination_location ON destination_location.id = offers.destination_location_id INNER JOIN tour_type ON tour_type.id=destination_location.tour_type_id INNER JOIN destinations ON destinations.id = destination_location.destinations_id INNER JOIN country ON country.id = destinations.country_id`);
        sql:Error? streamError = offersStream.forEach(function(DBOfferDetals offer) {
            offers.push(offer);
        });
        if streamError is sql:Error {
            check offersStream.close();
            return utils:setErrorResponse(response, "Error in retrieving offers");
        }
        response.setJsonPayload({
            "success": true,
            "content": offers.toJson()
        });
        return response;
    }

    resource function get admin/getLocations/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|error|http:Response {
        http:Response response = new;
        json[] locationWithReviews = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        stream<DBLocationDetails, sql:Error?> locationStream = self.connection->query(`
        SELECT destination_location.id AS location_id, 
               destination_location.title, 
               destination_location.image, 
               destination_location.overview, 
               tour_type.type AS tour_type, 
               destinations.title AS destination_title, 
               country.name AS country_name 
        FROM destination_location 
        INNER JOIN tour_type ON tour_type.id = destination_location.tour_type_id 
        INNER JOIN destinations ON destinations.id = destination_location.destinations_id 
        INNER JOIN country ON country.id = destinations.country_id
    `);

        sql:Error|() locationStreamError = locationStream.forEach(function(DBLocationDetails location) {
            LocationReviewDetails[] reviews = [];

            stream<LocationReviewDetails, sql:Error?> reviewStream = self.connection->query(`
            SELECT ratings.id AS rating_id, 
                   ratings.rating_count, 
                   ratings.review_img, 
                   ratings.review, 
                   user.first_name, 
                   user.last_name, 
                   user.email 
            FROM ratings 
            INNER JOIN user ON user.id = ratings.user_id 
            WHERE destination_location_id = ${location.location_id}
        `);
            sql:Error? reviewStreamError = reviewStream.forEach(function(LocationReviewDetails review) {
                reviews.push(review);
            });

            if reviewStreamError is sql:Error {
                return ();
            }

            json returnObject = {
                location: location.toJson(),
                reviews: reviews.toJson()
            };
            locationWithReviews.push(returnObject);
        });

        if locationStreamError is sql:Error {
            check locationStream.close();
            return utils:setErrorResponse(response, "Error in retrieving locations");
        }

        check locationStream.close();

        response.setJsonPayload({
            "success": true,
            "content": locationWithReviews
        });
        return response;
    }

    resource function get admin/getDestinations/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|error|http:Response {
        http:Response response = new;
        DBDestinationDetails[] destinations = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        stream<DBDestinationDetails, sql:Error?> destinationStream = self.connection->query(`SELECT destinations.id AS destination_id, destinations.title, destinations.image, destinations.description, country.name AS country_name FROM destinations INNER JOIN  country ON country.id = destinations.country_id`);
        sql:Error? streamError = destinationStream.forEach(function(DBDestinationDetails destination) {
            destinations.push(destination);
        });
        if streamError is sql:Error {
            check destinationStream.close();
            return utils:setErrorResponse(response, "Error in retrieving destinations");
        }
        response.setJsonPayload({
            "success": true,
            "content": destinations.toJson()
        });
        return response;
    }

    resource function put admin/updatePassword/[string BALUSERTOKEN](@http:Payload RequestPassword payload) returns http:Unauthorized & readonly|error|http:Response {
        http:Response response = new;
        map<string> errorMsg = {};
        boolean errorFlag = false;

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        if payload.user_id is "" {
            errorFlag = true;
            errorMsg["user_id"] = "User ID required";
        }
        if payload.new_password is "" {
            errorFlag = true;
            errorMsg["new_pw"] = "New password required";
        }
        if payload.old_password is "" {
            errorFlag = true;
            errorMsg["old_pw"] = "Old password required";
        }

        if errorFlag {
            return utils:setErrorResponse(response, errorMsg.toJson());
        }

        DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM admin  WHERE id = ${payload.user_id}`);
        if result is DBUser {
            boolean isOldPwVerify = password:verifyHmac(payload.old_password, result.password);
            if isOldPwVerify !is true {
                return utils:setErrorResponse(response, "Old password is incorrect");
            }
            string newHashedPw = password:generateHmac(payload.new_password);
            sql:ExecutionResult|sql:Error updateResult = self.connection->execute(`UPDATE admin SET password = ${newHashedPw} WHERE id  = ${payload.user_id}`);
            if updateResult is sql:Error {
                return utils:setErrorResponse(response, "Error updating password");
            }
            response.setJsonPayload({
                "success": true,
                "content": "Password updated successfully"
            });
        } else {
            return utils:setErrorResponse(response, "User not found");
        }

        return response;
    }

    resource function put admin/updateDestination/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
        http:Response res = new;
        map<any> formData = {};

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        if !utils:validateContentType(req.getContentType()) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:INVALID_CONTENT_TYPE);
        }

        map<any>|error multipartFormData = utils:parseMultipartFormData(req.getBodyParts(), formData);
        if multipartFormData is error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_MULTIPART_REQUEST);
        }

        if !formData.hasKey("destinationId") {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:REQUIRED_FIELDS_MISSING);
        }

        string destinationId = <string>formData["destinationId"];

        if int:fromString(destinationId) !is int {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_COUNTRY_ID);
        }

        DBDestination|sql:Error destinationResult = self.connection->queryRow(`SELECT * FROM destinations WHERE id=${destinationId}`);
        if destinationResult is sql:NoRowsError {
            return utils:returnResponseWithStatusCode(res, http:STATUS_NOT_FOUND, utils:DESTINATION_NOT_FOUND);
        } else if destinationResult is sql:Error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:DATABASE_ERROR);
        }

        if destinationResult is DBDestination {
            sql:ParameterizedQuery[] setClauses = [];
            if formData.hasKey("countryId") && formData["countryId"] is string {
                setClauses.push(<sql:ParameterizedQuery>`country_id = ${<string>formData["countryId"]}`);
            }
            if formData.hasKey("title") && formData["title"] is string {
                setClauses.push(`title = ${<string>formData["title"]}`);
            }
            if formData.hasKey("description") && formData["description"] is string {
                setClauses.push(<sql:ParameterizedQuery>`description = ${<string>formData["description"]}`);
            }
            if formData.hasKey("file") && formData["file"] is byte[] {
                boolean|error isDeleteImage = img:deleteImageFile(destinationResult.image);
                if isDeleteImage is false || isDeleteImage is error {
                    return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:IMAGE_DELETE);
                }
                string imageName = formData["title"] != "" ? <string>formData["title"] : destinationResult.title;
                string|error|io:Error? uploadedImage = img:uploadImage(<byte[]>formData["file"], "destinations/", imageName);

                if uploadedImage is error {
                    return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:IMAGE_UPLOAD);
                }
                setClauses.push(<sql:ParameterizedQuery>`image = ${uploadedImage}`);
            }

            if setClauses.length() > 0 {
                sql:ParameterizedQuery setPart = ``;
                boolean isFirst = true;
                foreach sql:ParameterizedQuery clause in setClauses {
                    if !isFirst {
                        setPart = sql:queryConcat(setPart, `, `, clause);
                    } else {
                        setPart = sql:queryConcat(setPart, clause);
                        isFirst = false;
                    }
                }
                sql:ParameterizedQuery queryConcat = sql:queryConcat(`UPDATE destinations SET `, setPart, ` WHERE id = ${destinationId} `);
                sql:ExecutionResult|sql:Error updateResult = self.connection->execute(queryConcat);
                if updateResult is sql:Error {
                    return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:DATABASE_ERROR);
                }
                return utils:returnResponseWithStatusCode(res, http:STATUS_CREATED, utils:DESTINATION_UPDATED, true);
            } else {
                return utils:returnResponseWithStatusCode(res, http:STATUS_OK, utils:DESTINATION_NO_FIELD);
            }
        }
        return res;
    }

    // resource function put admin/updateOffer/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
    //     mime:Entity[] parts = check req.getBodyParts();
    //     http:Response response = new;

    //     if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
    //         return http:UNAUTHORIZED;
    //     }

    //     if !utils:validateContentType(req) {
    //         return utils:setErrorResponse(response, "Unsupported content type. Expected multipart/form-data.");
    //     }
    //     if parts.length() == 0 {
    //         return utils:setErrorResponse(response, "Request body is empty");
    //     }
    //     string offerId = "";
    //     string fromDate = "";
    //     string title = "";
    //     string toDate = "";
    //     string locationId = "";
    //     boolean isImageInclude = false;
    //     foreach mime:Entity part in parts {
    //         string? dispositionName = part.getContentDisposition().name;
    //         string|mime:ParserError text = part.getText();
    //         if dispositionName is "offerId" {
    //             if text is string {
    //                 offerId = text;
    //             }
    //         } else if dispositionName is "fromDate" {
    //             if text is string {
    //                 fromDate = text;
    //             }
    //         } else if dispositionName is "title" {
    //             if text is string {
    //                 title = text;
    //             }
    //         } else if dispositionName is "toDate" {
    //             if text is string {
    //                 toDate = text;
    //             }
    //         } else if dispositionName is "locationId" {
    //             if text is string {
    //                 locationId = text;
    //             }
    //         } else if dispositionName is "file" {
    //             if !utils:validateImageFile(part) {
    //                 return utils:setErrorResponse(response, "Invalid or unsupported image file type");
    //             }
    //             isImageInclude = true;
    //         }
    //     }

    //     if offerId is "" {
    //         return utils:setErrorResponse(response, "Offer ID is required");
    //     }

    //     DBOffer|sql:Error offerResult = self.connection->queryRow(`SELECT * FROM offers WHERE id=${offerId}`);
    //     if offerResult is sql:NoRowsError {
    //         return utils:setErrorResponse(response, "Offer not found");
    //     } else if offerResult is sql:Error {
    //         return utils:setErrorResponse(response, "Error in retrieving offer");
    //     }

    //     if offerResult is DBOffer {
    //         sql:ParameterizedQuery[] setClauses = [];
    //         if locationId != "" {
    //             setClauses.push(<sql:ParameterizedQuery>`destination_location_id = ${locationId}`);
    //         }
    //         if title != "" {
    //             setClauses.push(`title = ${title}`);
    //         }
    //         if fromDate != "" {
    //             boolean isValidFromDate = regex:matches(fromDate, utils:DATETIME_REGEX);
    //             if isValidFromDate !is true {
    //                 return utils:setErrorResponse(response, "Invalid date format");
    //             }
    //             setClauses.push(<sql:ParameterizedQuery>`from_Date = ${fromDate}`);
    //         }
    //         if toDate != "" {
    //             boolean isValidToDate = regex:matches(toDate, utils:DATETIME_REGEX);
    //             if isValidToDate !is true {
    //                 return utils:setErrorResponse(response, "Invalid date format");
    //             }
    //             setClauses.push(<sql:ParameterizedQuery>`to_Date = ${toDate}`);
    //         }
    //         if isImageInclude {
    //             boolean|error isDeleteImage = img:deleteImageFile(offerResult.image);
    //             if isDeleteImage is false || isDeleteImage is error {
    //                 return utils:setErrorResponse(response, "Error in deleting image");
    //             }
    //             string imageName = title != "" ? title : offerResult.title;
    //             string|error|io:Error? uploadedImage = img:uploadImage(req, "offers/", imageName);

    //             if uploadedImage is error {
    //                 return utils:setErrorResponse(response, "Error in uploading image");
    //             }
    //             setClauses.push(<sql:ParameterizedQuery>`image = ${uploadedImage}`);
    //         }

    //         if setClauses.length() > 0 {
    //             sql:ParameterizedQuery setPart = ``;
    //             boolean isFirst = true;
    //             foreach sql:ParameterizedQuery clause in setClauses {
    //                 if !isFirst {
    //                     setPart = sql:queryConcat(setPart, `, `, clause);
    //                 } else {
    //                     setPart = sql:queryConcat(setPart, clause);
    //                     isFirst = false;
    //                 }
    //             }
    //             sql:ParameterizedQuery queryConcat = sql:queryConcat(`UPDATE offers SET `, setPart, ` WHERE id = ${offerId} `);
    //             sql:ExecutionResult|sql:Error updateResult = self.connection->execute(queryConcat);
    //             if updateResult is sql:Error {
    //                 return utils:setErrorResponse(response, "Error in updating offer");
    //             }
    //             response.setJsonPayload({"success": true, "content": "Successfully updated the offer"});
    //         } else {
    //             return utils:setErrorResponse(response, "No valid fields to update");
    //         }
    //     }
    //     return response;
    // }

    // resource function put admin/updateLocation/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
    //     mime:Entity[] parts = check req.getBodyParts();
    //     http:Response response = new;

    //     if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
    //         return http:UNAUTHORIZED;
    //     }

    //     if !utils:validateContentType(req) {
    //         return utils:setErrorResponse(response, "Unsupported content type. Expected multipart/form-data.");
    //     }
    //     if parts.length() == 0 {
    //         return utils:setErrorResponse(response, "Request body is empty");
    //     }
    //     string locationId = "";
    //     string tourTypeId = "";
    //     string title = "";
    //     string overview = "";
    //     string destinationId = "";
    //     boolean isImageInclude = false;
    //     foreach mime:Entity part in parts {
    //         string? dispositionName = part.getContentDisposition().name;
    //         string|mime:ParserError text = part.getText();
    //         if dispositionName is "locationId" {
    //             if text is string {
    //                 locationId = text;
    //             }
    //         } else if dispositionName is "tourTypeId" {
    //             if text is string {
    //                 tourTypeId = text;
    //             }
    //         } else if dispositionName is "title" {
    //             if text is string {
    //                 title = text;
    //             }
    //         } else if dispositionName is "overview" {
    //             if text is string {
    //                 overview = text;
    //             }
    //         } else if dispositionName is "destinationId" {
    //             if text is string {
    //                 destinationId = text;
    //             }
    //         } else if dispositionName is "file" {
    //             if !utils:validateImageFile(part) {
    //                 return utils:setErrorResponse(response, "Invalid or unsupported image file type");
    //             }
    //             isImageInclude = true;
    //         }
    //     }

    //     if locationId is "" {
    //         return utils:setErrorResponse(response, "Location ID is required");
    //     }

    //     DBLocation|sql:Error locationResult = self.connection->queryRow(`SELECT * FROM destination_location WHERE id=${locationId}`);
    //     if locationResult is sql:NoRowsError {
    //         return utils:setErrorResponse(response, "Destination location not found");
    //     } else if locationResult is sql:Error {
    //         return utils:setErrorResponse(response, "Error in retrieving destination location");
    //     }

    //     if locationResult is DBLocation {
    //         sql:ParameterizedQuery[] setClauses = [];
    //         if overview != "" {
    //             setClauses.push(<sql:ParameterizedQuery>`overview = ${overview}`);
    //         }
    //         if title != "" {
    //             setClauses.push(`title = ${title}`);
    //         }
    //         if tourTypeId != "" {
    //             setClauses.push(<sql:ParameterizedQuery>`tour_type_id = ${tourTypeId}`);
    //         }
    //         if tourTypeId != "" {
    //             setClauses.push(<sql:ParameterizedQuery>`destinations_id = ${destinationId}`);
    //         }
    //         if isImageInclude {
    //             boolean|error isDeleteImage = img:deleteImageFile(locationResult.image);
    //             if isDeleteImage is false || isDeleteImage is error {
    //                 return utils:setErrorResponse(response, "Error in deleting image");
    //             }
    //             string imageName = title != "" ? title : locationResult.title;
    //             string|error|io:Error? uploadedImage = img:uploadImage(req, "locations/", imageName);

    //             if uploadedImage is error {
    //                 return utils:setErrorResponse(response, "Error in uploading image");
    //             }
    //             setClauses.push(<sql:ParameterizedQuery>`image = ${uploadedImage}`);
    //         }

    //         if setClauses.length() > 0 {
    //             sql:ParameterizedQuery setPart = ``;
    //             boolean isFirst = true;
    //             foreach sql:ParameterizedQuery clause in setClauses {
    //                 if !isFirst {
    //                     setPart = sql:queryConcat(setPart, `, `, clause);
    //                 } else {
    //                     setPart = sql:queryConcat(setPart, clause);
    //                     isFirst = false;
    //                 }
    //             }
    //             sql:ParameterizedQuery queryConcat = sql:queryConcat(`UPDATE destination_location SET `, setPart, ` WHERE id = ${locationId} `);
    //             sql:ExecutionResult|sql:Error updateResult = self.connection->execute(queryConcat);
    //             if updateResult is sql:Error {
    //                 return utils:setErrorResponse(response, "Error in updating destination location");
    //             }
    //             response.setJsonPayload({"success": "Successfully updated the destination location"});
    //         } else {
    //             return utils:setErrorResponse(response, "No valid fields to update");
    //         }
    //     }
    //     return response;
    // }

}
