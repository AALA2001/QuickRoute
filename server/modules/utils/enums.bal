
public enum REGEXS {
    EMAIL_REGEX = "^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$",
    PASSWORD_REGEX = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$",
    DATETIME_REGEX = "^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}$"
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
    PASSWORD_REQUIRED = "Password is required",
    INCORRECT_OLD_PASSWORD = "Old password is incorrect",
    USER_NOT_FOUND = "User not found",
    PASSWORD_UPDATED = "Password updated successfully"
}

public enum COMMON_ERROR_MESSAGES {
    UNAUTHORIZED_REQUEST = "Unauthorized Request",
    INVALID_CONTENT_TYPE = "Invalid Content Type",
    INVALID_MULTIPART_REQUEST = "Invalid multipart request",
    REQUIRED_FIELDS_MISSING = "Required fields are missing"
}

public enum DESTINATION_ERRORS {
    INVALID_COUNTRY_ID = "Invalid country id",
    COUNTRY_NOT_FOUND = "Country not found",
    ERROR_FETCHING_COUNTRY = "Error in fetching country",
    ERROR_UPLOADING_IMAGE = "Error in uploading image",
    ERROR_FETCHING_DESTINATION = "Error in fetching destination",
    DESTINATION_ALREADY_EXISTS = "Destination already exists",
    IMAGE_DELETE = "Error deleting image",
    IMAGE_UPLOAD = "Error uploading image",
    DATABASE_ERROR = "Database error",
    DESTINATION_UPDATED = "Destination updated successfully",
    NO_FIELD = "No fields to update",
    DESTINATION_SUCCESS = "Successfully created destination"
}

public enum LOCATION_ERRORS {
    INVALID_DESTINATION_TOUTYPE_ID = "Invalid destination location and tour type Id",
    DESTINATION_NOT_FOUND = "Destination not found",
    TOURTYPE_NOT_FOUND = "Tour type not found",
    ERROR_FETCHING_TOURTYPE = "Error in fetching tour type",
    ERROR_UPLOADING_IMAGE = "Error in uploading image",
    DESTINATION_ALREADY_EXISTS = "Destination already exists",
    ERROR_FETCHING_DESTINATION_LOCATION = "Error in fetching destination location",
    DESTINATION_LOCATION_ALREADY_EXISTS = "Destination location already exists",
    LOCATION_SUCCESS = "Successfully created destination location",
    INVALID_LOCATION_ID = "Invalid location Id"
}

public enum OFFER_ERRORS {
    INVALID_DESTINATION_LOCATION_ID = "Invalid destination location",
    INVALID_DATETIME_FROMAT = "Invalid datetime format",
    DESTINATION_LOCATION_NOT_FOUND = "Destination location not found",
    OFFER_ALREADY_EXISTS = "Offer already exists",
    ERROR_FETCHING_OFFERS = "Error in fetching offers",
    OFFER_SUCCESS = "Successfully created offer",
    OFFER_UPDATED = "Successfully updated the offer",
    INVALID_OFFER_ID = "Invalid offer Id",
    OFFER_NOT_FOUND = "Offer not found"
}

public enum RATING_ERRORS {
    INVALID_USER_ID = "Invalid user Id",
    INVALID_RATING_COUNT = "Invalid rating count",
    REVIEW_CREATED = "Successfully added the review"
}