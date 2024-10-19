import ballerina/time;
import ballerina/regex;

public isolated function currentTimeStamp() returns string {
    time:Utc currTime = time:utcNow();
    string currentTimeStamp = time:utcToString(currTime);
    return currentTimeStamp;
}

public isolated function expierTimeStamp() returns string {
    time:Utc currTime = time:utcNow();
    time:Utc expiryTime = time:utcAddSeconds(currTime, 1800);
    string expiryTimeString = time:utcToString(expiryTime);
    return expiryTimeString;
}

public isolated function validateExpierTime(string currentTime, string expiryTime) returns boolean {
    if (currentTime <= expiryTime) {
        return true;
    } else {
        return false;
    }
}

public isolated function getUniqueIDByCurrentTime() returns string {
    time:Civil civilTime = time:utcToCivil(time:utcNow());
    string currentTimeString = civilTime.hour.toString() + civilTime.minute.toString() + civilTime.second.toString();
    string[] spliited = regex:split(currentTimeString, "\\.");
    string timeMil = spliited[0] + "" + spliited[1];
    return timeMil;
}
