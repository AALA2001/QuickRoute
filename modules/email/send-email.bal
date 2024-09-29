import ballerina/email;

configurable string server = ?;
configurable string username = ?;
configurable string password = ?;

public function sendEmail(string to, string subject, string body, string? cc = (), string? bcc = ()) returns boolean {
    do {
        email:SmtpClient smtpClient = check new (server, username, password);
        email:Message email = {
            to: to,
            cc: cc,
            bcc: bcc,
            subject: subject,
            body: body
        };
         check smtpClient->sendMessage(email);
        return true;
    } on fail {
        return false;
    }
}
