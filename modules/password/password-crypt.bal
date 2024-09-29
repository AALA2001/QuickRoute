import ballerina/crypto;

configurable string secret = ?;

public function generateHmac(string password) returns string {
    do {
        byte[] data = password.toBytes();
        byte[] key = secret.toBytes();
        byte[] hmac = check  crypto:hmacSha512(data, key);
        return hmac.toBase16();
    } on fail{
        return  "Error generating HMAC";
    }
}

public function verifyHmac(string passsword, string hashPassword) returns boolean {
    do {
        string generatedHmac = generateHmac(passsword);
        return generatedHmac == hashPassword;
    } on fail{
        return false;
    }
}
