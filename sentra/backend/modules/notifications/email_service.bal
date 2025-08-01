// modules/notifications/email_service.bal
import ballerina/email;

configurable string smtpHost = ?;
configurable int smtpPort = ?;
configurable string smtpUsername = ?;
configurable string smtpPassword = ?;

email:SmtpConfiguration smtpConfig = {
    port: smtpPort,
    security: email:START_TLS_AUTO
};

public isolated function sendNotificationEmail(string toEmail, string subject, string body) returns error? {
    email:Message message = {
        to: [toEmail],
        subject: subject,
        body: body,
        'from: smtpUsername,
        sender: smtpUsername
    };
    
    email:SmtpClient smtpClient = check new (smtpHost, smtpUsername, smtpPassword, smtpConfig);
    check smtpClient->send(message);
}