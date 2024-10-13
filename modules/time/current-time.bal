import ballerina/time;

public function currentTimeStamp() returns string {
    time:Utc currTime = time:utcNow();
    string currentTimeStamp = time:utcToString(currTime);
    return currentTimeStamp;
}

public function expierTimeStamp() returns string {
    time:Utc currTime = time:utcNow();
    time:Utc expiryTime = time:utcAddSeconds(currTime, 1800);
    string expiryTimeString = time:utcToString(expiryTime);
    return expiryTimeString;
}

public function validateExpierTime(string currentTime, string expiryTime) returns boolean {
    if (currentTime <= expiryTime) {
        return true;
    } else {
        return false;
    }
}
