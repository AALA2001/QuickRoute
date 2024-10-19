import QuickRoute.db;
import QuickRoute.filters;
import QuickRoute.img;
import QuickRoute.password;
import QuickRoute.utils;

import ballerina/http;
import ballerina/io;
import ballerina/regex;
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

    resource function post admin/addDestination/[string BALUSERTOKEN](http:Request req) returns http:Response|error? {
        http:Response res = new;
        map<any> formData = {};

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        if !utils:validateContentType(req.getContentType()) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNSUPPORTED_MEDIA_TYPE, utils:INVALID_CONTENT_TYPE);
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
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNSUPPORTED_MEDIA_TYPE, utils:INVALID_CONTENT_TYPE);
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
            return utils:returnResponseWithStatusCode(res, http:STATUS_CONFLICT, utils:DESTINATION_LOCATION_ALREADY_EXISTS);
        }
    }

    resource function post admin/addOffer/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
        http:Response res = new;
        map<any> formData = {};

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        if !utils:validateContentType(req.getContentType()) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNSUPPORTED_MEDIA_TYPE, utils:INVALID_CONTENT_TYPE);
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
            return utils:returnResponseWithStatusCode(res, http:STATUS_CONFLICT, utils:OFFER_ALREADY_EXISTS);
        }
    }

    resource function get admin/getCountries/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|error|http:Response {
        http:Response response = new;
        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(response, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }
        stream<DBCountry, sql:Error?> countryStream = self.connection->query(`SELECT * FROM country ORDER BY name ASC`);
        DBCountry[] countries = [];
        check from DBCountry country in countryStream
            do {
                countries.push(country);
            };
        check countryStream.close();
        return utils:returnResponseWithStatusCode(response, http:STATUS_OK, countries.toJson(), true);
    }

    resource function get admin/getTourTypes/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|error|http:Response {
        http:Response response = new;
        DBTourType[] tourTypes = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(response, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }
        stream<DBTourType, sql:Error?> tourTypeStream = self.connection->query(`SELECT * FROM tour_type ORDER BY type ASC`);
        check from DBTourType tourType in tourTypeStream
            do {
                tourTypes.push(tourType);
            };
        check tourTypeStream.close();
        return utils:returnResponseWithStatusCode(response, http:STATUS_OK, tourTypes.toJson(), true);
    }

    resource function get admin/getReviews/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|http:Response|sql:Error|error {
        http:Response response = new;
        DBReview[] reviews = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(response, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        stream<DBReview, sql:Error?> reviewStream = self.connection->query(`SELECT reviews.id AS review_id, user.first_name, user.last_name, user.email, reviews.review FROM reviews INNER JOIN user ON user.id = reviews.user_id`);
        check from DBReview review in reviewStream
            do {
                reviews.push(review);
            };
        check reviewStream.close();
        return utils:returnResponseWithStatusCode(response, http:STATUS_OK, reviews.toJson(), true);
    }

    resource function get admin/getOffers/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|error|http:Response {
        http:Response response = new;
        DBOfferDetals[] offers = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(response, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        stream<DBOfferDetals, sql:Error?> offersStream = self.connection->query(`SELECT offers.id AS offer_id, offers.from_Date, offers.to_Date, offers.title, offers.image, destination_location.title AS location_title, tour_type.type AS tour_type, destinations.title AS destination_title, country.name AS country_name FROM offers INNER JOIN destination_location ON destination_location.id = offers.destination_location_id INNER JOIN tour_type ON tour_type.id=destination_location.tour_type_id INNER JOIN destinations ON destinations.id = destination_location.destinations_id INNER JOIN country ON country.id = destinations.country_id ORDER BY offers.id DESC`);
        check from DBOfferDetals offer in offersStream
            do {
                offers.push(offer);
            };
        check offersStream.close();
        return utils:returnResponseWithStatusCode(response, http:STATUS_OK, offers.toJson(), true);
    }

    resource function get admin/getLocations/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|error|http:Response {
        http:Response response = new;
        json[] locations = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(response, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
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
        INNER JOIN country ON country.id = destinations.country_id ORDER BY destination_location.id DESC
    `);
        check from DBLocationDetails location in locationStream
            do {
                locations.push(location);
            };
        check locationStream.close();
        return utils:returnResponseWithStatusCode(response, http:STATUS_OK, locations, true);
    }

    resource function get admin/getLocationReviews/[string BALUSERTOKEN](int locationId) returns error|http:Response {
        http:Response response = new;
        json[] locationReviews = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(response, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

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
            WHERE destination_location_id = ${locationId}`);
        check from LocationReviewDetails review in reviewStream
            do {
                locationReviews.push(review);
            };
        check reviewStream.close();
        return utils:returnResponseWithStatusCode(response, http:STATUS_OK, locationReviews, true);
    }

    resource function get admin/getDestinations/[string BALUSERTOKEN]() returns http:Unauthorized & readonly|error|http:Response {
        http:Response response = new;
        DBDestinationDetails[] destinations = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(response, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        stream<DBDestinationDetails, sql:Error?> destinationStream = self.connection->query(`SELECT destinations.id AS destination_id, destinations.title, destinations.image, destinations.description, country.name AS country_name FROM destinations INNER JOIN  country ON country.id = destinations.country_id ORDER BY destinations.id DESC`);
        check from DBDestinationDetails destination in destinationStream
            do {
                destinations.push(destination);
            };
        check destinationStream.close();
        return utils:returnResponseWithStatusCode(response, http:STATUS_OK, destinations.toJson(), true);
    }

    resource function put admin/updatePassword/[string BALUSERTOKEN](@http:Payload RequestPassword payload) returns http:Unauthorized & readonly|error|http:Response {
        http:Response res = new;
        map<string> errorMsg = {};
        boolean errorFlag = false;

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        if payload.email is "" {
            errorFlag = true;
            errorMsg["email"] = "Email required";
        }
        if payload.new_password is "" {
            errorFlag = true;
            errorMsg["new_pw"] = "New password required";
        }
        if payload.old_password is "" {
            errorFlag = true;
            errorMsg["old_pw"] = "Old password required";
        }
        if !regex:matches(payload.new_password, utils:PASSWORD_REGEX) {
            errorFlag = true;
            errorMsg["new_pw"] = "Password must be at least 8 characters long and contain atleast one uppercase letter, one lowercase letter, one digit, and one special character";
        }

        if errorFlag {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, errorMsg.toJson());
        }

        DBUser|sql:Error result = self.connection->queryRow(`SELECT * FROM admin  WHERE email = ${payload.email}`);
        if result is DBUser {
            boolean isOldPwVerify = password:verifyHmac(payload.old_password, result.password);
            if isOldPwVerify !is true {
                return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INCORRECT_OLD_PASSWORD);
            }
            string newHashedPw = password:generateHmac(payload.new_password);
            sql:ExecutionResult|sql:Error updateResult = self.connection->execute(`UPDATE admin SET password = ${newHashedPw} WHERE email  = ${payload.email}`);
            if updateResult is sql:Error {
                return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:DATABASE_ERROR);
            }
            return utils:returnResponseWithStatusCode(res, http:STATUS_CREATED, utils:PASSWORD_UPDATED, true);
        } else {
            return utils:returnResponseWithStatusCode(res, http:STATUS_OK, utils:USER_NOT_FOUND);
        }
    }

    resource function put admin/updateDestination/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
        http:Response res = new;
        map<any> formData = {};

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        if !utils:validateContentType(req.getContentType()) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNSUPPORTED_MEDIA_TYPE, utils:INVALID_CONTENT_TYPE);
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
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:DESTINATION_NOT_FOUND);
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
                string imageName = formData["title"] !is () ? <string>formData["title"] : destinationResult.title;
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
                return utils:returnResponseWithStatusCode(res, http:STATUS_OK, utils:DESTINATION_UPDATED, true);
            } else {
                return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:NO_FIELD);
            }
        }
        return res;
    }

    resource function put admin/updateOffer/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
        http:Response res = new;
        map<any> formData = {};

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        if !utils:validateContentType(req.getContentType()) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNSUPPORTED_MEDIA_TYPE, utils:INVALID_CONTENT_TYPE);
        }

        map<any>|error multipartFormData = utils:parseMultipartFormData(req.getBodyParts(), formData);
        if multipartFormData is error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_MULTIPART_REQUEST);
        }

        if !formData.hasKey("offerId") {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:REQUIRED_FIELDS_MISSING);
        }

        string offerId = <string>formData["offerId"];

        if int:fromString(offerId) !is int {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_OFFER_ID);
        }

        DBOffer|sql:Error offerResult = self.connection->queryRow(`SELECT * FROM offers WHERE id=${offerId}`);
        if offerResult is sql:NoRowsError {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:OFFER_NOT_FOUND);
        } else if offerResult is sql:Error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_FETCHING_OFFERS);
        }

        if offerResult is DBOffer {
            sql:ParameterizedQuery[] setClauses = [];
            if formData.hasKey("locationId") && formData["locationId"] is string {
                setClauses.push(<sql:ParameterizedQuery>`destination_location_id = ${<string>formData["locationId"]}`);
            }
            if formData.hasKey("title") && formData["title"] is string {
                setClauses.push(`title = ${<string>formData["title"]}`);
            }
            if formData.hasKey("fromDate") && formData["fromDate"] is string {
                boolean isValidFromDate = regex:matches(<string>formData["fromDate"], utils:DATETIME_REGEX);
                if isValidFromDate !is true {
                    return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_DATETIME_FROMAT);
                }
                setClauses.push(<sql:ParameterizedQuery>`from_Date = ${<string>formData["fromDate"]}`);
            }
            if formData.hasKey("toDate") && formData["toDate"] is string {
                boolean isValidToDate = regex:matches(<string>formData["toDate"], utils:DATETIME_REGEX);
                if isValidToDate !is true {
                    return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_DATETIME_FROMAT);
                }
                setClauses.push(<sql:ParameterizedQuery>`to_Date = ${<string>formData["toDate"]}`);
            }
            if formData.hasKey("file") && formData["file"] is byte[] {
                boolean|error isDeleteImage = img:deleteImageFile(offerResult.image);
                if isDeleteImage is false || isDeleteImage is error {
                    return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:IMAGE_DELETE);
                }
                string imageName = formData["title"] != () ? <string>formData["title"] : offerResult.title;
                string|error|io:Error? uploadedImage = img:uploadImage(<byte[]>formData["file"], "offers/", imageName);

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
                sql:ParameterizedQuery queryConcat = sql:queryConcat(`UPDATE offers SET `, setPart, ` WHERE id = ${offerId} `);
                sql:ExecutionResult|sql:Error updateResult = self.connection->execute(queryConcat);
                if updateResult is sql:Error {
                    return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:DATABASE_ERROR);
                }
                return utils:returnResponseWithStatusCode(res, http:STATUS_OK, utils:OFFER_UPDATED, true);
            } else {
                return utils:returnResponseWithStatusCode(res, http:STATUS_OK, utils:NO_FIELD);
            }
        }
        return res;
    }

    resource function put admin/updateLocation/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
        http:Response res = new;
        map<any> formData = {};

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        if !utils:validateContentType(req.getContentType()) {
            return utils:returnResponseWithStatusCode(res, http:STATUS_UNSUPPORTED_MEDIA_TYPE, utils:INVALID_CONTENT_TYPE);
        }

        map<any>|error multipartFormData = utils:parseMultipartFormData(req.getBodyParts(), formData);
        if multipartFormData is error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_MULTIPART_REQUEST);
        }

        if !formData.hasKey("locationId") {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:REQUIRED_FIELDS_MISSING);
        }

        string locationId = <string>formData["locationId"];

        if int:fromString(locationId) !is int {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:INVALID_LOCATION_ID);
        }

        DBLocation|sql:Error locationResult = self.connection->queryRow(`SELECT * FROM destination_location WHERE id=${locationId}`);
        if locationResult is sql:NoRowsError {
            return utils:returnResponseWithStatusCode(res, http:STATUS_BAD_REQUEST, utils:DESTINATION_LOCATION_NOT_FOUND);
        } else if locationResult is sql:Error {
            return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:ERROR_FETCHING_DESTINATION_LOCATION);
        }

        if locationResult is DBLocation {
            sql:ParameterizedQuery[] setClauses = [];
            if formData.hasKey("overview") && formData["overview"] is string {
                setClauses.push(<sql:ParameterizedQuery>`overview = ${<string>formData["overview"]}`);
            }
            if formData.hasKey("title") && formData["title"] is string {
                setClauses.push(`title = ${<string>formData["title"]}`);
            }
            if formData.hasKey("tourTypeId") && formData["tourTypeId"] is string {
                setClauses.push(<sql:ParameterizedQuery>`tour_type_id = ${<string>formData["tourTypeId"]}`);
            }
            if formData.hasKey("destinationId") && formData["destinationId"] is string {
                setClauses.push(<sql:ParameterizedQuery>`destinations_id = ${<string>formData["destinationId"]}`);
            }
            if formData.hasKey("file") && formData["file"] is byte[] {
                boolean|error isDeleteImage = img:deleteImageFile(locationResult.image);
                if isDeleteImage is false || isDeleteImage is error {
                    return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:IMAGE_DELETE);
                }
                string imageName = formData["title"] != () ? <string>formData["title"] : locationResult.title;
                string|error|io:Error? uploadedImage = img:uploadImage(<byte[]>formData["file"], "locations/", imageName);

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
                sql:ParameterizedQuery queryConcat = sql:queryConcat(`UPDATE destination_location SET `, setPart, ` WHERE id = ${locationId} `);
                sql:ExecutionResult|sql:Error updateResult = self.connection->execute(queryConcat);
                if updateResult is sql:Error {
                    return utils:returnResponseWithStatusCode(res, http:STATUS_INTERNAL_SERVER_ERROR, utils:DATABASE_ERROR);
                }
                return utils:returnResponseWithStatusCode(res, http:STATUS_OK, utils:DESTINATION_UPDATED, true);
            } else {
                return utils:returnResponseWithStatusCode(res, http:STATUS_OK, utils:NO_FIELD);
            }
        }
        return res;
    }

    resource function get admin/getTotalCounts/[string BALUSERTOKEN]() returns error|http:Response {
        http:Response response = new;
        json totalCounts = {};
        DBReview[] reviews = [];
        json[] stats = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return utils:returnResponseWithStatusCode(response, http:STATUS_UNAUTHORIZED, utils:UNAUTHORIZED_REQUEST);
        }

        sql:Error|TotalCount destinationsCount = self.connection->queryRow(`SELECT COUNT(id) AS count FROM destinations`);
        sql:Error|TotalCount destinationLocationsCount = self.connection->queryRow(`SELECT COUNT(id) AS count FROM destination_location`);
        sql:Error|TotalCount offersCount = self.connection->queryRow(`SELECT COUNT(id) AS count FROM offers`);
        sql:Error|TotalCount reviewsCount = self.connection->queryRow(`SELECT COUNT(id) AS count FROM reviews`);

        if (destinationsCount is sql:Error ||
        destinationLocationsCount is sql:Error ||
        offersCount is sql:Error ||
        reviewsCount is sql:Error) {
            return utils:returnResponseWithStatusCode(response, http:STATUS_INTERNAL_SERVER_ERROR, utils:DATABASE_ERROR);
        }

        stream<DBReview, sql:Error?> reviewStream = self.connection->query(`SELECT reviews.id AS review_id, user.first_name, user.last_name, user.email, reviews.review FROM reviews INNER JOIN user ON user.id = reviews.user_id LIMIT 6`);
        check from DBReview review in reviewStream
            do {
                reviews.push(review);
            };
        check reviewStream.close();

        json[] tourTypesData = [];

        stream<DBTourType, sql:Error?> tourTypeStream = self.connection->query(`SELECT * FROM tour_type`);
        check from DBTourType tourType in tourTypeStream
            do {
                TotalCount|sql:Error countRow = self.connection->queryRow(`SELECT COUNT(id) AS count FROM destination_location WHERE tour_type_id = ${tourType.id}`);
                if countRow is TotalCount {
                    tourTypesData.push({"name": tourType.'type, "value": countRow.count}.toJson());
                }
            };
        check tourTypeStream.close();
        json tourTypes = {"label": "Tour Types", "data": tourTypesData.toJson()};
        stats.push(tourTypes);

        totalCounts = {
            "destinations": destinationsCount.count,
            "locations": destinationLocationsCount.count,
            "offers": offersCount.count,
            "reviews": reviewsCount.count,
            "reviewsList": reviews.toJson(),
            "stats": stats
        };
        return utils:returnResponseWithStatusCode(response, http:STATUS_OK, totalCounts, true);
    }

}

