import ballerina/time;

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
    string expiryTime;
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

public type DBCountry record {|
    int id;
    string name;
|};

public type DBDestination record {|
    int id;
    string title;
    string image;
    string description;
    int country_id;
|};

public type DBLocation record {|
    int id;
    string title;
    string image;
    string overview;
    int tour_type_id;
    int destinations_id;
|};

public type DBTourType record {|
    int id;
    string 'type;
|};

public type DBOffer record {|
    int id;
    time:Civil from_Date;
    time:Civil to_Date;
    string title;
    string image;
    int destination_location_id;
|};

public type DBReview record {|
    int review_id;
    string review;
    string first_name;
    string last_name;
    string email;
|};

public type DBOfferDetals record {|
    int offer_id;
    time:Civil from_Date;
    time:Civil to_Date;
    string title;
    string image;
    string location_title;
    string tour_type;
    string destination_title;
    string country_name;
|};

public type DBLocationDetails record {|
    int location_id;
    string title;
    string image;
    string overview;
    string tour_type;
    string destination_title;
    string country_name;
|};

public type DBDestinationDetails record {|
    int destination_id;
    string title;
    string image;
    string description;
    string country_name;
|};

public type RequestPassword record {|
    string user_id;
    string new_password;
    string old_password;
|};

public type UserHasPlans record {|
    int plan_id;
    int user_id;
    string plan_name;
|};

public type PlanRename record {|
    int plan_id;
    string new_name;
|};

public type siteReview record {|
    string review;
|};

public type wishlist record {|
    int id;
    int user_id;
    int destination_location_id;
|};
public type removeWishList record {|
    int destinations_id;
|};