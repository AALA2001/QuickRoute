// modules/auth/middleware.bal
import ballerina/http;

public isolated function authenticate(http:RequestContext ctx, http:Request req) returns User|error {
    string|http:HeaderNotFoundError authHeader = req.getHeader("Authorization");
    
    if authHeader is http:HeaderNotFoundError {
        return error("Authorization header missing");
    }
    
    if !authHeader.startsWith("Bearer ") {
        return error("Invalid authorization header format");
    }
    
    string token = authHeader.substring(7);
    var payload = validateToken(token);
    if payload is error {
        return error("Invalid token");
    }
    
    string userId = <string>payload.customClaims["userId"];
    
    // Fetch user details from database
    return check getUserById(userId);
}