import QuickRoute.db;
import QuickRoute.password;
import QuickRoute.email;

import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;

public function main() returns error?{
    Province[] provinceGetResult = check provinceGet();
    provinceGetResult.forEach(function(Province province) {
        io:println(province);
    });

    boolean booleanResult = email:sendEmail("virulnirmala24@gmail.com", "testing", "this is testing email");
    io:println(booleanResult);
     _ = passswordHasing();
   
};

public function provinceGet() returns Province[]|error {
    mysql:Client|sql:Error connection = db:getConnection();

    if connection is mysql:Client {
        stream<Province, sql:Error?> query = connection->query(`SELECT * FROM province`);
        Province[] provinces = [];
        check query.forEach(function(Province province) {
            provinces.push(province);
        });

        check connection.close();
        return provinces;
    } else {
        return connection;
    }
}

public function passswordHasing () {
    string generateHmacResult =  password:generateHmac("hello");
    io:println(generateHmacResult);

    boolean verifyHmacResult = password:verifyHmac("hello",generateHmacResult);
    io:println(verifyHmacResult);
}