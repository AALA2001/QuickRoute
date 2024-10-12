public type Province record {|
    int id;
    string name;
|};

public type DBUser record {|
    int id;
    string first_name;
    string last_name;
    string email;
    string password;
|};

public type UserDTO record {|
    string first_name;
    string last_name;
    string email;
    string userType;
|};

public type RequestUser record {|
    string first_name;
    string last_name;
    string email;
    string password;
|};

public type LoginUser record {|
    string email;
    string password;
|};

public type Destination record {|
    int id;
    string title;
    string productId;
    string productSlug;
    string taxonomySlug;
    string cityUfi;
    string cityName;
    string countryCode;
|};