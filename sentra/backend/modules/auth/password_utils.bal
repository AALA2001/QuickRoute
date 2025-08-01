// modules/auth/password_utils.bal
import ballerina/crypto;
import ballerina/random;

public isolated function hashPassword(string password) returns string|error {
    byte[] salt = check random:createIntArray(16);
    return crypto:hashSha256((password + salt.toString()).toBytes()).toBase64();
}

public isolated function verifyPassword(string password, string hashedPassword) returns boolean {
    // Simple implementation - in production, use proper salt storage
    string|error newHash = hashPassword(password);
    if newHash is error {
        return false;
    }
    return newHash == hashedPassword;
}