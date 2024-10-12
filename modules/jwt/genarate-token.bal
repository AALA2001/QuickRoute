import ballerina/crypto;
import ballerina/io;
import ballerina/mime;
import ballerina/regex;

configurable string secret = ?;

public function generateJWT(json payload) returns error|string {
    json header = {
        "alg": "HS256",
        "typ": "JWT"
    };

    string|byte[]|io:ReadableByteChannel encodedHeader = check mime:base64Encode(header.toString());
    string|byte[]|io:ReadableByteChannel encodedPayload = check mime:base64Encode(payload.toString());

    string signatureInput = <string>encodedHeader + "." + <string>encodedPayload;

    byte[] hmacMd5 = check crypto:hmacMd5(signatureInput.toBytes(), secret.toBytes());
    string|byte[]|io:ReadableByteChannel encodedSignature = check mime:base64Encode(hmacMd5.toString());
    return <string>encodedHeader + "." + <string>encodedPayload + "." + <string>encodedSignature;
}

public function decodeJWT(string jwt) returns json|error {

    string[] jwtParts = regex:split(jwt, "\\.");
    if jwtParts.length() != 3 {
        return error("Invalid JWT format.");
    }

    string encodedHeader = jwtParts[0];
    string encodedPayload = jwtParts[1];
    string encodedSignature = jwtParts[2];

    string|byte[]|io:ReadableByteChannel decodedPayloadBytes = check mime:base64Decode(encodedPayload);
    string decodedPayloadStr = decodedPayloadBytes.toString();
    json decodedPayload = decodedPayloadStr.toJson();

    string signatureInput = encodedHeader + "." + encodedPayload;
    byte[] expectedSignature = check crypto:hmacMd5(signatureInput.toBytes(), secret.toBytes());
    string|byte[]|io:ReadableByteChannel encodedExpectedSignature = check mime:base64Encode(expectedSignature.toString());

    if (encodedSignature != encodedExpectedSignature) {
        return error("Invalid JWT signature.");
    }

    return decodedPayload;
}
