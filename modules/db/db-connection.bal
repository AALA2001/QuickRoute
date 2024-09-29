import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;

configurable string host = ?;
configurable string username = ?;
configurable string passsword = ?;
configurable string database = ?;
configurable int port = ?;


mysql:Client|sql:Error dbClient = new (
    host,
    username,
    passsword,
    database,
    port
);

public function getConnection() returns  mysql:Client|sql:Error {
    return dbClient;
}