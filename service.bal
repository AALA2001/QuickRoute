import QuickRoute.db;
import QuickRoute.filters;
import QuickRoute.img;
import QuickRoute.jwt;
import QuickRoute.password;
import QuickRoute.time;
import QuickRoute.utils;

import ballerina/http;
import ballerina/io;
import ballerina/regex;
import ballerina/sql;
import ballerina/url;
import ballerinax/mysql;

http:ClientConfiguration clientEPConfig = {
    cookieConfig: {
        enabled: true
    }
};
listener http:Listener authEP = new (9091);
listener http:Listener adminEP = new (9092);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE"],
        allowCredentials: true
    }
}
service /auth on authEP {
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
                    io:println(token);
                    io:println(url:decode(token, "UTF-8"));
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
service /data on adminEP {

    private final mysql:Client connection;

    function init() returns error? {
        self.connection = db:getConnection();
    }

    function __deinit() returns sql:Error? {
        _ = checkpanic self.connection.close();
    }

    resource function post admin/addDestination/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|http:Response|error? {
        mime:Entity[] parts = check req.getBodyParts();
        http:Response response = new;

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        if !utils:validateContentType(req) {
            return utils:setErrorResponse(response, "Unsupported content type. Expected multipart/form-data.");
        }
        if parts.length() == 0 {
            return utils:setErrorResponse(response, "Request body is empty");
        }

        string countryId = "";
        string title = "";
        string description = "";
        boolean isImageInclude = false;
        foreach mime:Entity part in parts {
            string? dispositionName = part.getContentDisposition().name;
            string|mime:ParserError text = part.getText();
            if dispositionName is "country_id" {
                if text is string {
                    countryId = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving country_id field");
                }
            } else if dispositionName is "title" {
                if text is string {
                    title = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving title field");
                }
            } else if dispositionName is "description" {
                if text is string {
                    description = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving description field");
                }
            } else if dispositionName is "file" {
                if !utils:validateImageFile(part) {
                    return utils:setErrorResponse(response, "Invalid or unsupported image file type");
                }
                isImageInclude = true;
            }
        }

        if countryId is "" || title is "" || description is "" {
            return utils:setErrorResponse(response, "Parameters are empty");
        }
        if !isImageInclude {
            return utils:setErrorResponse(response, "Image is required");
        }

        if int:fromString(countryId) !is int {
            return utils:setErrorResponse(response, "Invalid type country id");
        }

        DBCountry|sql:Error countryResult = self.connection->queryRow(`SELECT * FROM country WHERE id=${countryId}`);
        if countryResult is sql:NoRowsError {
            return utils:setErrorResponse(response, "Country not found");
        } else if countryResult is sql:Error {
            return utils:setErrorResponse(response, "Error in retrieving country");
        }

        DBDestination|sql:Error desResult = self.connection->queryRow(`SELECT * FROM destinations WHERE title = ${title} AND country_id=${countryId}`);
        if desResult is sql:NoRowsError {
            string|error uploadedImagePath = img:uploadImage(req, "uploads/destinations/", title);
            if uploadedImagePath !is string {
                return utils:setErrorResponse(response, "Error in uploading image");
            }
            _ = check self.connection->execute(`INSERT INTO destinations (title, country_id, image, description) VALUES (${title}, ${countryId}, ${uploadedImagePath}, ${description})`);
            response.setJsonPayload({"success": true, "content": "Successfully uploaded destination"});
        } else if desResult is sql:Error {
            return utils:setErrorResponse(response, "Error in retrieving destination");
        } else {
            return utils:setErrorResponse(response, "Destination already exists");
        }
        return response;
    }

    resource function post admin/addLocation/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
        mime:Entity[] parts = check req.getBodyParts();
        http:Response response = new;

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        if !utils:validateContentType(req) {
            return utils:setErrorResponse(response, "Unsupported content type. Expected multipart/form-data.");
        }
        if parts.length() == 0 {
            return utils:setErrorResponse(response, "Request body is empty");
        }

        string destinationId = "";
        string tourTypeId = "";
        string title = "";
        string overview = "";
        boolean isImageInclude = false;
        foreach mime:Entity part in parts {
            string? dispositionName = part.getContentDisposition().name;
            string|mime:ParserError text = part.getText();
            if dispositionName is "destinationId" {
                if text is string {
                    destinationId = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving destinationId field");
                }
            } else if dispositionName is "tourTypeId" {
                if text is string {
                    tourTypeId = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving tourTypeId field");
                }
            } else if dispositionName is "title" {
                if text is string {
                    title = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving title field");
                }
            } else if dispositionName is "overview" {
                if text is string {
                    overview = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving overview field");
                }
            } else if dispositionName is "file" {
                if !utils:validateImageFile(part) {
                    return utils:setErrorResponse(response, "Invalid or unsupported image file type");
                }
                isImageInclude = true;
            }
        }

        if destinationId is "" || title is "" || overview is "" || tourTypeId is "" {
            return utils:setErrorResponse(response, "Parameters are empty");
        }
        if !isImageInclude {
            return utils:setErrorResponse(response, "Image is required");
        }

        if int:fromString(destinationId) !is int && int:fromString(tourTypeId) !is int {
            return utils:setErrorResponse(response, "Invalid destinationId or tourTypeId");
        }

        DBDestination|sql:Error desResult = self.connection->queryRow(`SELECT * FROM destinations WHERE id=${destinationId}`);
        DBTourType|sql:Error tourResult = self.connection->queryRow(`SELECT * FROM tour_type WHERE id=${tourTypeId}`);
        if desResult is sql:NoRowsError {
            return utils:setErrorResponse(response, "Destination not found");
        } else if desResult is sql:Error {
            return utils:setErrorResponse(response, "Error in retrieving destination");
        }
        if tourResult is sql:NoRowsError {
            return utils:setErrorResponse(response, "Tour type not found");
        } else if tourResult is sql:Error {
            return utils:setErrorResponse(response, "Error in retrieving tour type");
        }

        DBLocation|sql:Error locationResult = self.connection->queryRow(`SELECT * FROM  destination_location WHERE title=${title} AND destinations_id=${destinationId}`);
        if locationResult is sql:NoRowsError {
            string|error uploadedImagePath = img:uploadImage(req, "uploads/locations/", title);
            if uploadedImagePath !is string {
                return utils:setErrorResponse(response, "Error in uploading image");
            }
            _ = check self.connection->execute(`INSERT INTO destination_location (title,image,overview,tour_type_id,destinations_id) VALUES (${title},${uploadedImagePath},${overview},${tourTypeId},${destinationId})`);
            response.setJsonPayload({"success": true, "content": "Successfully uploaded destination location"});

        } else if locationResult is sql:Error {
            return utils:setErrorResponse(response, "Error in retrieving location");
        } else {
            return utils:setErrorResponse(response, "Destination location already exists");
        }
        return response;
    }

    resource function post admin/addOffer/[string BALUSERTOKEN](http:Request req) returns http:Unauthorized & readonly|error|http:Response {
        mime:Entity[] parts = check req.getBodyParts();
        http:Response response = new;

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        if !utils:validateContentType(req) {
            return utils:setErrorResponse(response, "Unsupported content type. Expected multipart/form-data.");
        }
        if parts.length() == 0 {
            return utils:setErrorResponse(response, "Request body is empty");
        }

        string destinationLocationId = "";
        string fromDate = "";
        string toDate = "";
        string title = "";
        boolean isImageInclude = false;
        foreach mime:Entity part in parts {
            string? dispositionName = part.getContentDisposition().name;
            string|mime:ParserError text = part.getText();
            if dispositionName is "destinationLocationId" {
                if text is string {
                    destinationLocationId = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving destination location id");
                }
            } else if dispositionName is "fromDate" {
                if text is string {
                    fromDate = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving from date");
                }
            } else if dispositionName is "toDate" {
                if text is string {
                    toDate = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving to date");
                }
            } else if dispositionName is "title" {
                if text is string {
                    title = text;
                } else {
                    return utils:setErrorResponse(response, "Error in retrieving title");
                }
            } else if dispositionName is "file" {
                if !utils:validateImageFile(part) {
                    return utils:setErrorResponse(response, "Invalid or unsupported image file type");
                }
                isImageInclude = true;
            }
        }

        string pattern = "^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}$";
        boolean isValidFromDate = regex:matches(fromDate, pattern);
        boolean isValidToDate = regex:matches(toDate, pattern);

        if destinationLocationId is "" || fromDate is "" || toDate is "" || title is "" {
            return utils:setErrorResponse(response, "Missing required fields");
        }
        if !isImageInclude {
            return utils:setErrorResponse(response, "Image is required");
        }
        if int:fromString(destinationLocationId) !is int {
            return utils:setErrorResponse(response, "Invalid destination location id");
        }

        if isValidFromDate !is true && isValidToDate !is true {
            return utils:setErrorResponse(response, "Invalid date format");
        }

        DBLocation|sql:Error desLocResult = self.connection->queryRow(`SELECT * FROM destination_location WHERE id=${destinationLocationId}`);
        if desLocResult is sql:NoRowsError {
            return utils:setErrorResponse(response, "Destination location not found");
        } else if desLocResult is sql:Error {
            return utils:setErrorResponse(response, "Error in retrieving destination location");
        }

        DBOffer|sql:Error offerResult = self.connection->queryRow(`SELECT * FROM  offers WHERE title=${title} AND destination_location_id=${destinationLocationId} AND to_Date=${toDate} AND from_Date=${fromDate}`);
        if offerResult is sql:NoRowsError {
            string|error uploadedImagePath = img:uploadImage(req, "uploads/offers/", title);
            if uploadedImagePath !is string {
                return utils:setErrorResponse(response, "Error in uploading image");
            } else {
                _ = check self.connection->execute(`INSERT INTO offers (title,image,to_Date,from_Date,destination_location_id) VALUES (${title},${uploadedImagePath},${toDate},${fromDate},${destinationLocationId})`);
                response.setJsonPayload({"success": true, "content": "Successfully uploaded offer"});
            }
        } else if offerResult is sql:Error {
            return utils:setErrorResponse(response, "Error in retrieving offer");
        } else {
            return utils:setErrorResponse(response, "Offer already exists");
        }
        return response;
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
        DBLocationDetails[] locations = [];

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        stream<DBLocationDetails, sql:Error?> locationStream = self.connection->query(`SELECT destination_location.id AS location_id, destination_location.title, destination_location.image, destination_location.overview, tour_type.type AS tour_type, destinations.title AS destination_title,country.name AS country_name FROM destination_location INNER JOIN tour_type ON tour_type.id=destination_location.tour_type_id INNER JOIN destinations ON destinations.id=destination_location.destinations_id INNER JOIN country  ON country.id = destinations.country_id`);
        sql:Error? strwamError = locationStream.forEach(function(DBLocationDetails location) {
            locations.push(location);
        });
        if strwamError is sql:Error {
            check locationStream.close();
            return utils:setErrorResponse(response, "Error in retrieving locations");
        }
        response.setJsonPayload({
            "success": true,
            "content": locations.toJson()
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
        mime:Entity[] parts = check req.getBodyParts();
        http:Response response = new;

        if (!check filters:requestFilterAdmin(BALUSERTOKEN)) {
            return http:UNAUTHORIZED;
        }

        if !utils:validateContentType(req) {
            return utils:setErrorResponse(response, "Unsupported content type. Expected multipart/form-data.");
        }
        if parts.length() == 0 {
            return utils:setErrorResponse(response, "Request body is empty");
        }
        string destinationId = "";
        string countryId = "";
        string title = "";
        string description = "";
        boolean isImageInclude = false;
        foreach mime:Entity part in parts {
            string? dispositionName = part.getContentDisposition().name;
            string|mime:ParserError text = part.getText();
            if dispositionName is "destinationId" {
                if text is string {
                    destinationId = text;
                }
            } else if dispositionName is "country_id" {
                if text is string {
                    countryId = text;
                }
            } else if dispositionName is "title" {
                if text is string {
                    title = text;
                }
            } else if dispositionName is "description" {
                if text is string {
                    description = text;
                }
            } else if dispositionName is "file" {
                if !utils:validateImageFile(part) {
                    return utils:setErrorResponse(response, "Invalid or unsupported image file type");
                }
                isImageInclude = true;
            }
        }

        if destinationId is "" {
            return utils:setErrorResponse(response, "Destination ID is required");
        }

        DBDestination|sql:Error desResult = self.connection->queryRow(`SELECT * FROM destinations WHERE id=${destinationId}`);
        if desResult is sql:NoRowsError {
            return utils:setErrorResponse(response, "Destination not found");
        } else if desResult is sql:Error {
            return utils:setErrorResponse(response, "Error in retrieving destination");
        }

        if desResult is DBDestination {
            sql:ParameterizedQuery[] setClauses = [];
            if countryId != "" {
                setClauses.push(<sql:ParameterizedQuery>`country_id = ${countryId}`);
            }
            if title != "" {
                setClauses.push(`title = ${title}`);
            }
            if description != "" {
                setClauses.push(<sql:ParameterizedQuery>`description = ${description}`);
            }
            if isImageInclude {
                boolean|error isDeleteImage = img:deleteImageFile(desResult.image);
                if isDeleteImage is false || isDeleteImage is error {
                    return utils:setErrorResponse(response, "Error in deleting image");
                }
                string imageName = title != "" ? title : desResult.title;
                string|error uploadedImage = img:uploadImage(req, "uploads/destinations/", imageName);

                if uploadedImage is error {
                    return utils:setErrorResponse(response, "Error in uploading image");
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
                    return utils:setErrorResponse(response, "Error in updating destination");
                }
                response.setJsonPayload({"success": "Successfully updated the destination"});
            } else {
                return utils:setErrorResponse(response, "No valid fields to update");
            }
        }

        return response;
    }
}
