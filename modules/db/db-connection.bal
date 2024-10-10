import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string host = ?;
configurable string username = ?;
configurable string passsword = ?;
configurable string database = ?;
configurable int port = ?;


final mysql:Client dbClient = check  new (
    host,
    username,
    passsword,
    database,
    port
);

public function getConnection() returns  mysql:Client{
    return dbClient;
}