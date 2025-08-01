# Sentra - Community-Powered Cyber Threat Monitoring System

![Sentra Logo](https://img.shields.io/badge/Sentra-Cyber%20Threat%20Monitoring-blue)
![Ballerina](https://img.shields.io/badge/Backend-Ballerina-red)
![React](https://img.shields.io/badge/Frontend-React-blue)
![MySQL](https://img.shields.io/badge/Database-MySQL-orange)

## 🛡️ Overview

Sentra is a comprehensive cyber threat monitoring system that empowers communities to collaborate in identifying, reporting, and validating security threats. Built with modern technologies, it provides real-time threat detection, automatic validation, and community-driven security intelligence.

### ✨ Key Features

- **🔐 Secure Authentication**: JWT-based authentication with password hashing
- **📧 Breach Detection**: Automatic email breach monitoring via HaveIBeenPwned API
- **📊 Threat Reporting**: Community-driven threat submission system
- **🤖 Automatic Validation**: VirusTotal API integration for URL scanning
- **👨‍💼 Admin Dashboard**: Comprehensive management interface
- **🔔 Real-time Notifications**: Email and in-app notification system
- **📱 Modern UI**: Responsive React frontend with Material-UI

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Frontend │    │ Ballerina Backend│    │   MySQL Database │
│                 │◄──►│                 │◄──►│                 │
│  - Dashboard    │    │  - REST API     │    │  - User Data    │
│  - Auth Forms   │    │  - JWT Auth     │    │  - Reports      │
│  - Admin Panel  │    │  - Async Tasks  │    │  - Notifications│
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  External APIs  │
                    │                 │
                    │ - HaveIBeenPwned│
                    │ - VirusTotal    │
                    │ - SMTP Server   │
                    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18.x or higher
- **Ballerina** Swan Lake 2201.9.0+
- **MySQL** 8.0+
- **API Keys**: HaveIBeenPwned, VirusTotal

### 1. Clone and Setup

```bash
git clone <repository-url>
cd sentra

# Run initial setup
./scripts/setup.sh
```

### 2. Configure Environment

Update `backend/resources/Config.toml`:

```toml
[database]
host = "localhost"
port = 3306
user = "your_db_user"
password = "your_db_password"
database = "sentra_db"

[external_apis]
hibp_api_key = "your-hibp-api-key"
virustotal_api_key = "your-virustotal-api-key"
```

### 3. Setup Database

```bash
mysql -u root -p < database/schema.sql
```

### 4. Start Application

```bash
./scripts/start.sh
```

Visit `http://localhost:3000` to access Sentra!

## 📁 Project Structure

```
sentra/
├── backend/                 # Ballerina backend
│   ├── modules/
│   │   ├── auth/           # Authentication module
│   │   ├── breach/         # Breach checking module
│   │   ├── reports/        # Threat reporting module
│   │   ├── notifications/  # Notification system
│   │   └── database/       # Database utilities
│   ├── resources/          # Config files
│   ├── tests/              # Test files
│   └── main.bal           # Main service file
├── frontend/               # React frontend
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── contexts/       # React contexts
│   │   └── services/       # API services
│   └── public/             # Static files
├── database/               # MySQL schema files
├── docs/                  # Documentation
└── scripts/               # Utility scripts
```

## 🔧 API Documentation

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/signup` | User registration |
| POST | `/api/login` | User login |
| GET | `/api/me` | Get user profile |

### Report Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/reports` | Submit threat report |
| GET | `/api/reports` | Get all reports |
| PUT | `/api/admin/reports/{id}/validate` | Validate report |

### Notification Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/notifications` | Get notifications |
| PUT | `/api/notifications/{id}/read` | Mark as read |
| GET | `/api/notifications/unread-count` | Get unread count |

## 🛠️ Development

### Backend Development

```bash
cd backend
bal build          # Build project
bal test           # Run tests
bal run            # Start development server
```

### Frontend Development

```bash
cd frontend
npm install        # Install dependencies
npm start          # Start development server
npm test           # Run tests
npm run build      # Build for production
```

### Database Migrations

```bash
mysql -u your_user -p sentra_db < database/schema.sql
```

## 🔒 Security Features

- **JWT Authentication** with secure token validation
- **Password Hashing** using cryptographic functions
- **SQL Injection Prevention** via parameterized queries
- **Input Validation** on all user inputs
- **CORS Protection** for cross-origin requests
- **Rate Limiting** (configurable)

## 🧪 Testing

### Backend Tests

```bash
cd backend
bal test
```

### Frontend Tests

```bash
cd frontend
npm test
```

### API Testing

```bash
# Test health endpoint
curl http://localhost:8080/api/health

# Test authentication
curl -X POST http://localhost:8080/api/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","name":"Test User"}'
```

## 📊 Monitoring & Logging

- **Application Logs**: Ballerina built-in logging
- **Access Logs**: HTTP request/response logging
- **Error Tracking**: Comprehensive error handling
- **Performance Metrics**: Built-in observability

## 🚢 Deployment

### Production Build

```bash
# Backend
cd backend && bal build

# Frontend
cd frontend && npm run build
```

### Docker Deployment (Optional)

```dockerfile
# Dockerfile.backend
FROM ballerina/ballerina:swan-lake-latest
COPY backend/ /app/
WORKDIR /app
RUN bal build
CMD ["bal", "run"]

# Dockerfile.frontend
FROM node:18-alpine
COPY frontend/ /app/
WORKDIR /app
RUN npm install && npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

### Environment Variables

```bash
export DB_HOST=localhost
export DB_USER=sentra_user
export DB_PASSWORD=secure_password
export JWT_SECRET=your-jwt-secret
export HIBP_API_KEY=your-hibp-key
export VT_API_KEY=your-virustotal-key
```

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow **clean code** principles
- Write **comprehensive tests**
- Update **documentation**
- Follow **security best practices**

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Troubleshooting

Common issues and solutions:

1. **Backend won't start**: Check MySQL connection and API keys
2. **Frontend build fails**: Verify Node.js version and dependencies
3. **Database connection errors**: Ensure MySQL is running and accessible

### Getting Help

- 📖 Read the [Setup Guide](docs/setup.md)
- 🐛 Report bugs via GitHub Issues
- 💬 Join our community discussions
- 📧 Contact: support@sentra-security.com

## 🔄 Changelog

### v1.0.0 (Current)
- ✅ User authentication system
- ✅ Breach detection integration
- ✅ Threat reporting system
- ✅ VirusTotal validation
- ✅ Admin dashboard
- ✅ Notification system
- ✅ React frontend

### Roadmap
- 🔄 Mobile app
- 🔄 Advanced analytics
- 🔄 API rate limiting
- 🔄 Multi-language support

## 🏆 Acknowledgments

- **Ballerina** team for the excellent language and platform
- **HaveIBeenPwned** for breach detection API
- **VirusTotal** for URL scanning services
- **Material-UI** for the beautiful React components
- **React** community for the awesome framework

---

**Made with ❤️ for the cybersecurity community**