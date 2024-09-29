import ballerina/io;
configurable string secret = ?;

public function main() {
    io:print("SECRET: ", secret);
}