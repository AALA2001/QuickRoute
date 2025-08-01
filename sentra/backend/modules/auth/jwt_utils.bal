// modules/auth/jwt_utils.bal
import ballerina/jwt;
import ballerina/time;

configurable string jwtSecret = ?;
configurable int jwtExpiry = ?;

public isolated function generateToken(string userId, string email) returns string|error {
    jwt:IssuerConfig issuerConfig = {
        username: userId,
        issuer: "sentra",
        audience: ["sentra-users"],
        expTime: time:utcNow() + jwtExpiry,
        customClaims: {
            "email": email,
            "userId": userId
        }
    };
    
    return jwt:issue(issuerConfig, jwtSecret);
}

public isolated function validateToken(string token) returns jwt:Payload|error {
    jwt:ValidatorConfig validatorConfig = {
        issuer: "sentra",
        audience: "sentra-users"
    };
    
    return jwt:validate(token, jwtSecret, validatorConfig);
}