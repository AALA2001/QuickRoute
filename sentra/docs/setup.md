# Sentra - Cyber Threat Monitoring System

## Overview
Sentra is a community-powered cyber threat monitoring system built with Ballerina backend and React frontend. It provides:

- **User Authentication**: JWT-based secure authentication
- **Breach Detection**: Integration with HaveIBeenPwned API for email breach monitoring
- **Threat Reporting**: Community-driven threat report submission system
- **Automatic Validation**: VirusTotal API integration for URL scanning
- **Admin Dashboard**: Manual validation and management interface
- **Notification System**: Real-time alerts and email notifications

## Prerequisites

### System Requirements
- **Operating System**: Linux, macOS, or Windows
- **Node.js**: Version 18.x or higher
- **MySQL**: Version 8.0 or higher
- **Ballerina**: Swan Lake 2201.9.0 or later

### API Keys Required
1. **HaveIBeenPwned API Key**: [Get here](https://haveibeenpwned.com/API/Key)
2. **VirusTotal API Key**: [Get here](https://www.virustotal.com/gui/join-us)
3. **SMTP Credentials**: For email notifications (Gmail, etc.)

## Installation

### 1. Install Ballerina
```bash
# Download and install Ballerina
curl -sSL https://dist.ballerina.io/downloads/swan-lake-latest/ballerina-installer-linux-x64.deb -o ballerina.deb
sudo dpkg -i ballerina.deb

# Verify installation
bal version
```

### 2. Install MySQL
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install mysql-server

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure installation
sudo mysql_secure_installation
```

### 3. Install Node.js
```bash
# Using NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

## Configuration

### 1. Database Setup
```bash
# Login to MySQL as root
sudo mysql -u root -p

# Create database and user
mysql> CREATE DATABASE sentra_db;
mysql> CREATE USER 'sentra_user'@'localhost' IDENTIFIED BY 'your_strong_password';
mysql> GRANT ALL PRIVILEGES ON sentra_db.* TO 'sentra_user'@'localhost';
mysql> FLUSH PRIVILEGES;
mysql> EXIT;

# Import schema
mysql -u sentra_user -p sentra_db < database/schema.sql
```

### 2. Backend Configuration
Update `backend/resources/Config.toml`:

```toml
[database]
host = "localhost"
port = 3306
user = "sentra_user"
password = "your_database_password"
database = "sentra_db"

[security]
jwt_secret = "your-super-secret-jwt-key-change-in-production"
jwt_expiry = 86400  # 24 hours

[external_apis]
hibp_api_key = "your-hibp-api-key"
virustotal_api_key = "your-virustotal-api-key"

[email]
smtp_host = "smtp.gmail.com"
smtp_port = 587
smtp_username = "your-email@gmail.com"
smtp_password = "your-app-password"
```

### 3. Environment Variables (Optional)
For production, use environment variables instead of config file:

```bash
export DB_HOST=localhost
export DB_USER=sentra_user
export DB_PASSWORD=your_database_password
export DB_NAME=sentra_db
export JWT_SECRET=your-secret-key
export HIBP_API_KEY=your-hibp-key
export VT_API_KEY=your-virustotal-key
export SMTP_USERNAME=your-email@gmail.com
export SMTP_PASSWORD=your-app-password
```

## Running the Application

### 1. Start Backend
```bash
cd backend
bal run
```
Backend will start on `http://localhost:8080`

### 2. Start Frontend
```bash
cd frontend
npm install
npm start
```
Frontend will start on `http://localhost:3000`

## Usage

### User Registration
1. Navigate to `http://localhost:3000`
2. Click "Sign Up" and create an account
3. Upon registration, an automatic breach scan is triggered

### Submitting Threat Reports
1. Login to your account
2. Navigate to "Submit Report"
3. Fill in threat details, suspicious URLs, and evidence
4. Submit - automatic VirusTotal validation will begin

### Admin Functions
1. Admin users can access the Admin Dashboard
2. Review submitted reports
3. Manually validate or reject reports
4. Add remarks and change status

### Breach Monitoring
- Automatic breach scans on user registration
- Manual breach scans available from dashboard
- Email notifications for detected breaches

## API Endpoints

### Authentication
- `POST /api/signup` - User registration
- `POST /api/login` - User login
- `GET /api/me` - Get current user profile

### Reports
- `POST /api/reports` - Submit threat report
- `GET /api/reports` - Get all reports
- `PUT /api/admin/reports/{id}/validate` - Admin validation

### Notifications
- `GET /api/notifications` - Get user notifications
- `PUT /api/notifications/{id}/read` - Mark as read
- `GET /api/notifications/unread-count` - Get unread count

### Breach Detection
- `GET /api/breach-logs` - Get user breach logs
- `POST /api/breach-scan` - Initiate manual scan

## Development

### Backend Development
```bash
cd backend
bal build
bal test
```

### Frontend Development
```bash
cd frontend
npm run build
npm test
```

### Database Migration
When updating schema:
```bash
mysql -u sentra_user -p sentra_db < database/schema.sql
```

## Security Considerations

1. **JWT Secret**: Use a strong, unique secret in production
2. **Database Credentials**: Use strong passwords and limit privileges
3. **API Keys**: Store securely and rotate regularly
4. **HTTPS**: Use SSL/TLS in production
5. **Input Validation**: All user inputs are validated
6. **SQL Injection**: Parameterized queries prevent SQL injection

## Troubleshooting

### Backend Issues
- Check Ballerina logs for errors
- Verify database connection
- Ensure all API keys are configured

### Frontend Issues
- Check browser console for errors
- Verify backend is running on port 8080
- Check network requests in developer tools

### Database Issues
- Verify MySQL service is running
- Check database permissions
- Ensure schema is properly imported

## Production Deployment

### Backend
```bash
cd backend
bal build
# Deploy the generated JAR file
```

### Frontend
```bash
cd frontend
npm run build
# Serve the build directory with nginx or Apache
```

### Database
- Use managed database service (AWS RDS, etc.)
- Enable SSL connections
- Regular backups and monitoring

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review API documentation
3. Check system logs
4. Contact system administrator

## License

This project is licensed under the MIT License.