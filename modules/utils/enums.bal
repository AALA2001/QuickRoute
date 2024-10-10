
public enum REGEXS {
    EMAIL_REGEX = "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$",
    PASSWORD_REGEX = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$"
}
public enum EMAIL_ERRORS {
    EMAIL_LENGTH = "Email should not exceed 200",
    EMAIL_REQUIRED = "Email is required",
    EMAIL_ALREADY_EXISTS = "Email already exists",
    EMAIL_NOT_FOUND = "Email not found",
    EMAIL_INVALID_FORMAT = "Invalid email format"
}
public enum FNAME_ERRORS {
    FNAME_LENGTH = "First name should not exceed 45",
    FNAME_REQUIRED = "First name is required"
}
public enum LNAME_ERRORS {
    LNAME_LENGTH = "Last name should not exceed 45",
    LNAME_REQUIRED = "Last name is required"
}
public enum PASSWORD_ERRORS {
    PASSWORD_LENGTH = "Password should be minimum 8 characters in length, shouldcontain at least one uppercase letter, one lowercase letter, at  least one digit and at least one special character",
    PASSWORD_REQUIRED = "Password is required"
}
