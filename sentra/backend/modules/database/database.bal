// modules/database/database.bal
import ballerina/sql;
import ballerinax/mysql;
import ballerina/uuid;

configurable string host = ?;
configurable int port = ?;
configurable string user = ?;
configurable string password = ?;
configurable string database = ?;

public isolated function getConnection() returns mysql:Client|sql:Error {
    return new ({
        host: host,
        port: port,
        user: user,
        password: password,
        database: database
    });
}

public isolated function generateId() returns string {
    return uuid:createType1AsString();
}