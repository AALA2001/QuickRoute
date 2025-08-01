// modules/auth/auth_service.bal
import sentra.database;
import ballerina/sql;
import ballerina/time;
import ballerinax/mysql;

public isolated function registerUser(SignupRequest request) returns AuthResponse|error {
    mysql:Client dbClient = check database:getConnection();
    
    // Check if user exists
    sql:ParameterizedQuery checkQuery = `SELECT id FROM users WHERE email = ${request.email}`;
    stream<record{}, sql:Error?> resultStream = dbClient->query(checkQuery);
    
    record{}|error? existingUser = resultStream.next();
    if existingUser is record{} {
        return error("User already exists");
    }
    
    // Hash password
    string hashedPassword = check hashPassword(request.password);
    string userId = database:generateId();
    
    // Insert user
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO users (id, email, password_hash, name) 
        VALUES (${userId}, ${request.email}, ${hashedPassword}, ${request.name})
    `;
    
    _ = check dbClient->execute(insertQuery);
    
    // Generate token
    string token = check generateToken(userId, request.email);
    
    User user = {
        id: userId,
        email: request.email,
        name: request.name,
        created_at: time:utcNow().toString()
    };
    
    return {token: token, user: user};
}

public isolated function loginUser(LoginRequest request) returns AuthResponse|error {
    mysql:Client dbClient = check database:getConnection();
    
    sql:ParameterizedQuery query = `
        SELECT id, email, name, password_hash, created_at 
        FROM users WHERE email = ${request.email}
    `;
    
    stream<record{}, sql:Error?> resultStream = dbClient->query(query);
    record{}|error? result = resultStream.next();
    
    if result is error || result is () {
        return error("Invalid credentials");
    }
    
    record{} userRecord = <record{}>result;
    string storedHash = <string>userRecord["password_hash"];
    
    if !verifyPassword(request.password, storedHash) {
        return error("Invalid credentials");
    }
    
    string userId = <string>userRecord["id"];
    string token = check generateToken(userId, request.email);
    
    User user = {
        id: userId,
        email: <string>userRecord["email"],
        name: <string>userRecord["name"],
        created_at: <string>userRecord["created_at"]
    };
    
    return {token: token, user: user};
}

public isolated function getUserById(string userId) returns User|error {
    mysql:Client dbClient = check database:getConnection();
    
    sql:ParameterizedQuery query = `
        SELECT id, email, name, created_at 
        FROM users WHERE id = ${userId}
    `;
    
    stream<record{}, sql:Error?> resultStream = dbClient->query(query);
    record{}|error? result = resultStream.next();
    
    if result is error || result is () {
        return error("User not found");
    }
    
    record{} userRecord = <record{}>result;
    
    return {
        id: <string>userRecord["id"],
        email: <string>userRecord["email"],
        name: <string>userRecord["name"],
        created_at: <string>userRecord["created_at"]
    };
}