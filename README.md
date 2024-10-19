# QuickRoute
![Logo](https://i.imghippo.com/files/cp1ga1729308804.png)

QuickRoute is an AI-based itinerary-generating web application that allows users to create personalized travel plans. The application supports two user roles: admin and user. 

## User Roles and Features

### Admin
- Manage destinations
- Manage destination locations
- Manage offers
- View site and destination location reviews

### User
- Register and log in to the system
- Add destination locations to a wishlist
- Create trip plans and add destination locations to the plans
- Write reviews for the site and destination locations
- Generate two AI-suggested itineraries from their trip plans
- Choose the most suitable itinerary and download it

## Tech Stack

- **Frontend:** React framework
- **Backend:** Ballerina
- **Database:** MySQL
- **AI Model:** GPT-3.5 Turbo for itinerary generation

## Authentication and Authorization

The application uses JWT tokens for authentication and authorization, with the following approach:
- **Algorithm:** HS256
- **Header:** Type `jwt`
- **Payload:** Encoded as base64
- **Secret:** Stored in `config.toml` file
- Custom modules were developed for generating and decoding JWT tokens.

### Request Filtering
A request filter module filters requests based on user roles.

## Application Modules

To ensure clean code and reusability, the following modules were developed:
- **DB Module:** Singleton module for database interactions
- **Email Module:** For handling email services
- **Image Upload Module:** For managing file uploads
- **Time Module:** For time-related functionalities
- **Password Module:** For encrypting user passwords using a secret stored in `config.toml`
- **Itinerary Generation Module:** Integrates with GPT-3.5 Turbo for AI-based itinerary suggestions

### Services Structure
- Admin services are maintained in `admin_services.bal`
- Client services are maintained in `client_services.bal`
- Authentication services, including login, registration, and admin login, are handled in `auth_service.bal`
- Static server file access is managed in `auth_service.bal`
- File uploading uses multipart form data handling in Ballerina

### Additional Features
- **Enums:** For regex and error messages
- **Validation Methods:** Separate methods for various validations

### Demo
![Untitleddesign-ezgif com-video-to-gif-converter (1)](https://github.com/user-attachments/assets/9d072b02-0da3-4d01-9428-98923cf91176)

## Setup Instructions

### Prerequisites
- **Ballerina:** Download and install [Ballerina](https://ballerina.io/downloads/).
- **Node.js and npm:** Ensure that Node.js and npm are installed.

### Steps to Run the Project

1. **Clone the Git repository:**
   ```bash
   git clone https://github.com/hiranyasemindi/iwb470-byte-seekers.git
   ```

2. **Frontend Setup:**
   ```bash
   cd client
   npm install
   npm run dev
   ```

3. **Database Setup:**
   - Inside the project file tree, there is a `QuickRoute.sql` file. Run this file to create the database schema.
   - Update the database configuration in `config.toml` under the `[QuickRoute.db]` section:
     - `host`
     - `username`
     - `password`
     - `database`
     - `port`

4. **Email Module Configuration:**
   - Update the email server configuration in `config.toml`:
     - `server`
     - `username`
     - `password`

5. **AI Module Configuration:**
   - In `config.toml`, configure the following:
     - `API_TOKEN`: Provide your OpenAI API token.
     - `API_URL`: Set this to `https://api.openai.com/v1/chat/completions`.

6. **Start the Ballerina Server:**
   - Use the Ballerina extension or run the following command in the project root:
     ```bash
     bal run
     ```

### Special Note
Make sure you have installed Ballerina before running the server. You can download Ballerina from [here](https://ballerina.io/downloads/).


## Contributing
- [@iamvirul](https://www.github.com/iamvirul)
- [@hiranyasemindi](https://www.github.com/hiranyasemindi)
- [@tilaknagunawardhane](https://www.github.com/tilaknagunawardhane)

## Contact
- [@virulnirmala](https://www.facebook.com/virulnirmala)
- [@hiranyasemindi](https://www.facebook.com/hiranyasemindi)
- [@tilaknagunawardhane](https://www.facebook.com/tilaknagunawardhane)
