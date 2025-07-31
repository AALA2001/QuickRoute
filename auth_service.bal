// Authentication Service for CyberCare
import CyberCare.db;
import CyberCare.auth;
import CyberCare.breach;
import CyberCare.notification;

import ballerina/http;
import ballerina/log;
import ballerina/time;
import ballerina/regex;

// HTTP listener for authentication service
listener http:Listener authListener = new (
    configurable int `CyberCare.server.port`,
    config = {
        cors: {
            allowOrigins: configurable string[] `CyberCare.server.cors_allowed_origins`,
            allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            allowHeaders: ["Content-Type", "Authorization"],
            allowCredentials: true
        }
    }
);

@http:ServiceConfig {
    basePath: "/api/auth"
}
service / on authListener {
    
    // User Registration
    resource function post signup(UserSignupRequest signupRequest) returns AuthResponse|http:BadRequest|http:InternalServerError {
        log:printInfo("User signup attempt for email: " + signupRequest.email);
        
        // Validate input
        ValidationError[]|() validationErrors = validateSignupRequest(signupRequest);
        if validationErrors is ValidationError[] {
            return <http:BadRequest>{
                body: {
                    success: false,
                    message: "Validation failed",
                    'error: validationErrors
                }
            };
        }
        
        // Check if user already exists
        User|error? existingUser = db:getUserByEmail(signupRequest.email);
        if existingUser is User {
            return <http:BadRequest>{
                body: {
                    success: false,
                    message: "User with this email already exists"
                }
            };
        } else if existingUser is error {
            log:printError("Database error while checking existing user", existingUser);
            return <http:InternalServerError>{
                body: {
                    success: false,
                    message: "Internal server error"
                }
            };
        }
        
        // Hash password
        string|error hashedPassword = auth:hashPassword(signupRequest.password);
        if hashedPassword is error {
            log:printError("Password hashing failed", hashedPassword);
            return <http:InternalServerError>{
                body: {
                    success: false,
                    message: "Failed to process registration"
                }
            };
        }
        
        // Create user
        string userId = auth:generateId("user");
        User newUser = {
            id: userId,
            email: signupRequest.email,
            name: signupRequest.name,
            passwordHash: hashedPassword,
            emailVerified: false,
            role: "user",
            createdAt: time:utcNow()
        };
        
        // Save user to database
        error? createResult = db:createUser(newUser);
        if createResult is error {
            log:printError("Failed to create user in database", createResult);
            return <http:InternalServerError>{
                body: {
                    success: false,
                    message: "Failed to create user account"
                }
            };
        }
        
        // Perform breach check
        BreachScanLog|error breachResult = breach:performRegistrationBreachCheck(userId, signupRequest.email);
        if breachResult is BreachScanLog && breachResult.status == "breached" {
            // Send breach notification
            _ = start notification:sendBreachNotification(userId, breachResult.breachedIn);
        }
        
        // Generate JWT token
        string|error token = auth:generateToken(newUser);
        if token is error {
            log:printError("Token generation failed", token);
            return <http:InternalServerError>{
                body: {
                    success: false,
                    message: "Registration successful but login failed"
                }
            };
        }
        
        // Create user profile response
        UserProfile userProfile = {
            id: newUser.id,
            email: newUser.email,
            name: newUser.name,
            breachHistory: breachResult is BreachScanLog ? [breachResult] : [],
            emailVerified: newUser.emailVerified,
            createdAt: newUser.createdAt
        };
        
        log:printInfo("User registration successful for: " + signupRequest.email);
        
        return {
            success: true,
            message: "Registration successful",
            token: token,
            user: userProfile
        };
    }
    
    // User Login
    resource function post login(UserLoginRequest loginRequest) returns AuthResponse|http:BadRequest|http:Unauthorized|http:InternalServerError {
        log:printInfo("User login attempt for email: " + loginRequest.email);
        
        // Validate input
        if loginRequest.email.trim() == "" || loginRequest.password.trim() == "" {
            return <http:BadRequest>{
                body: {
                    success: false,
                    message: "Email and password are required"
                }
            };
        }
        
        // Get user from database
        User|error? user = db:getUserByEmail(loginRequest.email);
        
        if user is () {
            return <http:Unauthorized>{
                body: {
                    success: false,
                    message: "Invalid email or password"
                }
            };
        } else if user is error {
            log:printError("Database error during login", user);
            return <http:InternalServerError>{
                body: {
                    success: false,
                    message: "Internal server error"
                }
            };
        }
        
        // Verify password
        boolean|error passwordValid = auth:verifyPassword(loginRequest.password, user.passwordHash);
        if passwordValid is error {
            log:printError("Password verification error", passwordValid);
            return <http:InternalServerError>{
                body: {
                    success: false,
                    message: "Authentication failed"
                }
            };
        }
        
        if !passwordValid {
            return <http:Unauthorized>{
                body: {
                    success: false,
                    message: "Invalid email or password"
                }
            };
        }
        
        // Update last login
        error? updateResult = db:updateUserLastLogin(user.id);
        if updateResult is error {
            log:printWarn("Failed to update last login time", updateResult);
        }
        
        // Generate JWT token
        string|error token = auth:generateToken(user);
        if token is error {
            log:printError("Token generation failed during login", token);
            return <http:InternalServerError>{
                body: {
                    success: false,
                    message: "Login failed"
                }
            };
        }
        
        // Get breach history
        BreachScanLog[]|error breachHistory = db:getBreachHistoryByUserId(user.id);
        if breachHistory is error {
            log:printError("Failed to get breach history", breachHistory);
            breachHistory = [];
        }
        
        // Create user profile response
        UserProfile userProfile = {
            id: user.id,
            email: user.email,
            name: user.name,
            breachHistory: breachHistory is BreachScanLog[] ? breachHistory : [],
            emailVerified: user.emailVerified,
            createdAt: user.createdAt
        };
        
        log:printInfo("User login successful for: " + loginRequest.email);
        
        return {
            success: true,
            message: "Login successful",
            token: token,
            user: userProfile
        };
    }
    
    // Get current user profile
    resource function get me(@http:Header string? authorization) returns UserProfile|http:Unauthorized|http:InternalServerError {
        string|error token = extractTokenFromHeader(authorization);
        if token is error {
            return <http:Unauthorized>{
                body: {
                    success: false,
                    message: "Authentication required"
                }
            };
        }
        
        string|error userId = auth:extractUserIdFromToken(token);
        if userId is error {
            return <http:Unauthorized>{
                body: {
                    success: false,
                    message: "Invalid authentication token"
                }
            };
        }
        
        User|error? user = db:getUserById(userId);
        if user is () {
            return <http:Unauthorized>{
                body: {
                    success: false,
                    message: "User not found"
                }
            };
        } else if user is error {
            log:printError("Database error while getting user profile", user);
            return <http:InternalServerError>{
                body: {
                    success: false,
                    message: "Failed to get user profile"
                }
            };
        }
        
        // Get breach history
        BreachScanLog[]|error breachHistory = db:getBreachHistoryByUserId(user.id);
        if breachHistory is error {
            log:printError("Failed to get breach history", breachHistory);
            breachHistory = [];
        }
        
        return {
            id: user.id,
            email: user.email,
            name: user.name,
            breachHistory: breachHistory is BreachScanLog[] ? breachHistory : [],
            emailVerified: user.emailVerified,
            createdAt: user.createdAt
        };
    }
    
    // Refresh JWT token
    resource function post refresh(@http:Header string? authorization) returns AuthResponse|http:Unauthorized|http:InternalServerError {
        string|error token = extractTokenFromHeader(authorization);
        if token is error {
            return <http:Unauthorized>{
                body: {
                    success: false,
                    message: "Authentication required"
                }
            };
        }
        
        string|error newToken = auth:refreshToken(token);
        if newToken is error {
            return <http:Unauthorized>{
                body: {
                    success: false,
                    message: "Invalid or expired token"
                }
            };
        }
        
        return {
            success: true,
            message: "Token refreshed successfully",
            token: newToken
        };
    }
    
    // Logout (client-side token removal, server-side is stateless)
    resource function post logout() returns APIResponse {
        return {
            success: true,
            message: "Logged out successfully"
        };
    }
}

// Helper function to extract token from Authorization header
isolated function extractTokenFromHeader(string? authHeader) returns string|error {
    if authHeader is () {
        return error("Authorization header missing");
    }
    
    string[] parts = regex:split(authHeader, " ");
    if parts.length() != 2 || parts[0] != "Bearer" {
        return error("Invalid authorization header format");
    }
    
    return parts[1];
}

// Validate signup request
isolated function validateSignupRequest(UserSignupRequest request) returns ValidationError[]|() {
    ValidationError[] errors = [];
    
    // Validate email
    if request.email.trim() == "" {
        errors.push({
            'field: "email",
            message: "Email is required"
        });
    } else {
        string emailPattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
        regex:RegExp|error emailRegex = regex:fromString(emailPattern);
        
        if emailRegex is regex:RegExp {
            if !emailRegex.isFullMatch(request.email) {
                errors.push({
                    'field: "email",
                    message: "Invalid email format"
                });
            }
        }
    }
    
    // Validate password
    if request.password.trim() == "" {
        errors.push({
            'field: "password",
            message: "Password is required"
        });
    } else if request.password.length() < 8 {
        errors.push({
            'field: "password",
            message: "Password must be at least 8 characters long"
        });
    }
    
    // Validate name
    if request.name.trim() == "" {
        errors.push({
            'field: "name",
            message: "Name is required"
        });
    } else if request.name.length() < 2 {
        errors.push({
            'field: "name",
            message: "Name must be at least 2 characters long"
        });
    }
    
    return errors.length() > 0 ? errors : ();
}