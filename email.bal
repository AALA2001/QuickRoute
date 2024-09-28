import ballerina/email;
import ballerina/http;

service / on new http:Listener(8080) {

    resource function get sendEmail() returns error|boolean {
        email:SmtpClient smtpClient = check new ("smtp.gmail.com", "hiranyagunawardhane@gmail.com", "hguy gxbe gxmu dlkb");

        email:Message email = {
            to: "hiranyasemindi@icloud.com",
            cc: "hiranyasemindi@icloud.com",
            bcc: "hiranyasemindi@icloud.com",
            subject: "Sample Email",
            body: "This is a sample email."
        };

        check smtpClient->sendMessage(email);
        return true;
    }
}
