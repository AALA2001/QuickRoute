import QuickRoute.jwt;
import QuickRoute.time;

import ballerina/data.jsondata;

public type UserDTO record {|
    string first_name;
    string last_name;
    string email;
    string userType;
    string expiryTime;
|};

public isolated function requestFilterAdmin(string BALUSERTOKEN) returns boolean|error {
    json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
    UserDTO payload = check jsondata:parseString(decodeJWT.toString());
    if payload.userType is "admin" {
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            return true;
        } else {
            return false;
        }
    }
    return false;
}

public isolated function requestFilterUser(string BALUSERTOKEN) returns boolean|error {
    json decodeJWT = check jwt:decodeJWT(BALUSERTOKEN);
    UserDTO payload = check jsondata:parseString(decodeJWT.toString());
    if payload.userType is "user" {
        if (time:validateExpierTime(time:currentTimeStamp(), payload.expiryTime)) {
            return true;
        } else {
            return false;
        }
    }
    return false;
}
