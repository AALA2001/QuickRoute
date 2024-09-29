import ballerina/crypto;
import ballerina/io;

public function generateHmac(string input, string secret) returns string|error {
    byte[] data = input.toBytes();
    byte[] key = secret.toBytes();
    byte[] hmac = check crypto:hmacSha512(data, key);
    return hmac.toBase16();
}

public function verifyHmac(string input, string secret, string receivedHmac) returns boolean|error {
    string generatedHmac = check generateHmac(input, secret);
    return generatedHmac == receivedHmac;
}

public function ballerinaFunction() returns error? {
    string input = "Hello Ballerina";
    string secret = "some-secret";
    
    string hmac = check generateHmac(input, secret);
    io:println("Generated HMAC: " + hmac);
    string receivedHmac = hmac;

    boolean isValid = check verifyHmac(input, secret, receivedHmac);
    io:println("Is the HMAC valid? " + isValid.toString());

    return;
}
