// JWT Authentication Module for CyberCare
import ballerina/jwt;
import ballerina/time;
import ballerina/crypto;
import ballerina/log;

// JWT Configuration
configurable string jwtSecret = ?;
configurable string jwtIssuer = ?;
configurable int jwtExpiryTime = ?;

// Generate JWT token for user
public isolated function generateToken(User user) returns string|error {
    time:Utc currentTime = time:utcNow();
    int iat = <int>currentTime[0]; // issued at
    int exp = iat + jwtExpiryTime; // expiration time
    
    JWTClaims claims = {
        sub: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
        exp: exp,
        iat: iat,
        iss: jwtIssuer
    };
    
    jwt:IssuerConfig issuerConfig = {
        username: user.email,
        issuer: jwtIssuer,
        audience: ["CyberCare"],
        expTime: exp,
        customClaims: {
            "sub": user.id,
            "email": user.email,
            "name": user.name,
            "role": user.role
        }
    };
    
    string|jwt:Error token = jwt:issue(issuerConfig, jwtSecret);
    
    if token is jwt:Error {
        log:printError("Failed to generate JWT token", token);
        return error("Failed to generate authentication token");
    }
    
    return token;
}

// Validate JWT token and extract claims
public isolated function validateToken(string token) returns JWTClaims|error {
    jwt:ValidatorConfig validatorConfig = {
        issuer: jwtIssuer,
        audience: ["CyberCare"],
        clockSkew: 60 // 60 seconds tolerance
    };
    
    jwt:Payload|jwt:Error payload = jwt:validate(token, jwtSecret, validatorConfig);
    
    if payload is jwt:Error {
        log:printError("JWT validation failed", payload);
        return error("Invalid authentication token");
    }
    
    // Extract custom claims
    json sub = payload.customClaims["sub"];
    json email = payload.customClaims["email"];
    json name = payload.customClaims["name"];
    json role = payload.customClaims["role"];
    
    if !(sub is string && email is string && name is string && role is string) {
        return error("Invalid token claims");
    }
    
    JWTClaims claims = {
        sub: sub,
        email: email,
        name: name,
        role: role,
        exp: <int>payload.exp,
        iat: <int>payload.iat,
        iss: payload.iss
    };
    
    return claims;
}

// Extract user ID from JWT token
public isolated function extractUserIdFromToken(string token) returns string|error {
    JWTClaims claims = check validateToken(token);
    return claims.sub;
}

// Extract user role from JWT token
public isolated function extractUserRoleFromToken(string token) returns string|error {
    JWTClaims claims = check validateToken(token);
    return claims.role;
}

// Check if user has required role
public isolated function hasRole(string token, string requiredRole) returns boolean|error {
    string userRole = check extractUserRoleFromToken(token);
    
    match requiredRole {
        "admin" => {
            return userRole == "admin";
        }
        "cert_viewer" => {
            return userRole == "admin" || userRole == "cert_viewer";
        }
        "user" => {
            return userRole == "admin" || userRole == "cert_viewer" || userRole == "user";
        }
        _ => {
            return false;
        }
    }
}

// Check if user is admin
public isolated function isAdmin(string token) returns boolean|error {
    return check hasRole(token, "admin");
}

// Check if user is CERT viewer or admin
public isolated function isCertViewer(string token) returns boolean|error {
    return check hasRole(token, "cert_viewer");
}

// Check if token is expired
public isolated function isTokenExpired(string token) returns boolean|error {
    JWTClaims claims = check validateToken(token);
    time:Utc currentTime = time:utcNow();
    int currentTimestamp = <int>currentTime[0];
    
    return claims.exp < currentTimestamp;
}

// Refresh token (generate new token with updated expiry)
public isolated function refreshToken(string oldToken) returns string|error {
    JWTClaims claims = check validateToken(oldToken);
    
    // Create a temporary user object for token generation
    User tempUser = {
        id: claims.sub,
        email: claims.email,
        name: claims.name,
        passwordHash: "", // Not needed for token refresh
        role: claims.role,
        createdAt: time:utcNow()
    };
    
    return check generateToken(tempUser);
}

// Hash password with salt
public isolated function hashPassword(string password) returns string|error {
    configurable string passwordSalt = ?;
    string saltedPassword = password + passwordSalt;
    byte[] hashedBytes = crypto:hashSha256(saltedPassword.toBytes());
    return hashedBytes.toBase64();
}

// Verify password
public isolated function verifyPassword(string password, string hashedPassword) returns boolean|error {
    string newHash = check hashPassword(password);
    return newHash == hashedPassword;
}

// Generate secure random ID
public isolated function generateId(string prefix) returns string {
    time:Utc currentTime = time:utcNow();
    int timestamp = <int>currentTime[0];
    int nanoSeconds = <int>currentTime[1];
    
    return prefix + "_" + timestamp.toString() + "_" + nanoSeconds.toString();
}