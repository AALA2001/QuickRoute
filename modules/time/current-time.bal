import ballerina/time;

public function currentTimeStamp() returns string {
    time:Civil civilTime = time:utcToCivil(time:utcNow());
    string currentTimeString = civilTime.hour.toString() + civilTime.minute.toString() + civilTime.second.toString();
    return currentTimeString;
}

public function expierTimeStamp() returns string {
    time:Civil civilTime = time:utcToCivil(time:utcNow());
    civilTime.minute = civilTime.minute + 30;
    if (civilTime.minute >= 60) {
        civilTime.minute = civilTime.minute - 60;
        civilTime.hour = civilTime.hour + 1;
    }
    if (civilTime.hour >= 24) {
        civilTime.hour = civilTime.hour - 24;
    }
    string expiryTimeString = civilTime.hour.toString() + civilTime.minute.toString() + civilTime.second.toString();
    return expiryTimeString;
}

public function validateExpierTime(string  currentTime, string expiryTime) returns boolean {
    if  (currentTime <= expiryTime) {
        return true;
    }else {
        return false;
    }
}
