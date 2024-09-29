import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type Province record {|
    int id;
    string name;
|};

service / on new http:Listener(8080) {
    private final mysql:Client db;

    function init() returns error? {
        self.db = check new ("localhost", "root", "Hiru2005@", "perfumeX", 3306);
    }

    resource function get albums() returns Province[]|error {
        stream<Province, sql:Error?> provinceStream = self.db->query(`SELECT * FROM province`);

        return from Province province in provinceStream
            select province;
    }
}
