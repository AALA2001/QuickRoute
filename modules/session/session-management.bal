import ballerina/http;
import ballerina/random;

public type User record {
    string first_name;
    string last_name;
    string email;
};

public isolated function createSessionCookie(User user) returns http:Cookie[]|error {
    float sessionID = random:createDecimal();
    http:Cookie sessionCookie = new ("BALSESSIONID", sessionID.toString(), path = "/");
    http:Cookie userCookie = new ("BALUSER", user.toString(), path = "/");
    return [sessionCookie, userCookie];
}

public function getUser(http:Request req) returns string|http:NotFound{
    http:Cookie[] cookies = req.getCookies();
    http:Cookie[] usernameCookie = cookies.filter(function(http:Cookie cookie) returns boolean {
        return cookie.name == "BALSESSIONID";
    });

    if usernameCookie.length() > 0 {
        string? user = usernameCookie[0].value;
        if user is string {
            return user;
        }
    }
    return http:NOT_FOUND;
}
