import ballerina/http;
import ballerina/random;

listener http:Listener serverEP = new (9090);

service / on serverEP {

    resource function get login() returns http:Response|http:Unauthorized|error {
        float sessionID = random:createDecimal();
        http:Cookie cookie = new ("BALSESSIONID", sessionID.toString(), path = "/");
        http:Response response = new;
        response.addCookie(cookie);
        response.setTextPayload("Login succeeded");
        return response;
    }

    resource function get welcome(http:Request req) returns string|http:NotFound {

        http:Cookie[] cookies = req.getCookies();
        http:Cookie[] usernameCookie = cookies.filter(function(http:Cookie cookie) returns boolean {
            return cookie.name == "BALSESSIONID";
        });

        if usernameCookie.length() > 0 {
            string? user = usernameCookie[0].value;
            if user is string {
                return  user;
            }
        }
        return http:NOT_FOUND;
    }
}
