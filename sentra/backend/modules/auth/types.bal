// modules/auth/types.bal

public type User record {
    string id;
    string email;
    string name;
    string created_at;
};

public type LoginRequest record {
    string email;
    string password;
};

public type SignupRequest record {
    string email;
    string password;
    string name;
};

public type AuthResponse record {
    string token;
    User user;
};