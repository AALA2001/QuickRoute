#!/bin/bash

# Sentra Initial Setup Script

echo "🔧 Setting up Sentra Cyber Threat Monitoring System..."

# Check if running as root for system installations
if [[ $EUID -eq 0 ]]; then
   echo "⚠️  This script should not be run as root for security reasons"
   exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check system requirements
echo "📋 Checking system requirements..."

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node --version | cut -d'v' -f2)
    echo "✅ Node.js found: v$NODE_VERSION"
else
    echo "❌ Node.js not found. Please install Node.js 18.x or higher"
    echo "   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
    echo "   sudo apt-get install -y nodejs"
    exit 1
fi

# Check Ballerina
if command_exists bal; then
    BAL_VERSION=$(bal version | head -n1)
    echo "✅ Ballerina found: $BAL_VERSION"
else
    echo "❌ Ballerina not found. Please install Ballerina Swan Lake"
    echo "   curl -sSL https://dist.ballerina.io/downloads/swan-lake-latest/ballerina-installer-linux-x64.deb -o ballerina.deb"
    echo "   sudo dpkg -i ballerina.deb"
    exit 1
fi

# Check MySQL
if command_exists mysql; then
    echo "✅ MySQL client found"
else
    echo "❌ MySQL client not found. Please install MySQL"
    echo "   sudo apt update && sudo apt install mysql-server mysql-client"
    exit 1
fi

# Create project structure if not exists
echo "📁 Setting up project structure..."
mkdir -p {backend,frontend,database,docs,scripts}

# Setup backend dependencies
echo "🔧 Setting up backend..."
cd backend
if [ ! -f "Ballerina.toml" ]; then
    echo "⚠️  Ballerina.toml not found. Please ensure you're in the correct directory."
    exit 1
fi

# Build backend to check for dependency issues
echo "🔨 Building backend..."
bal build
if [ $? -ne 0 ]; then
    echo "❌ Backend build failed. Please check dependencies."
    exit 1
fi
cd ..

# Setup frontend dependencies
echo "🎨 Setting up frontend..."
cd frontend
if [ ! -f "package.json" ]; then
    echo "⚠️  package.json not found. Please ensure you're in the correct directory."
    exit 1
fi

echo "📦 Installing frontend dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "❌ Frontend dependency installation failed."
    exit 1
fi
cd ..

# Database setup prompt
echo ""
echo "🗄️  Database Setup Required:"
echo "1. Ensure MySQL is running: sudo systemctl start mysql"
echo "2. Create database: mysql -u root -p < database/schema.sql"
echo "3. Update backend/resources/Config.toml with your database credentials"
echo ""

# Configuration reminder
echo "⚙️  Configuration Required:"
echo "1. Get HaveIBeenPwned API key: https://haveibeenpwned.com/API/Key"
echo "2. Get VirusTotal API key: https://www.virustotal.com/gui/join-us"
echo "3. Configure SMTP settings for email notifications"
echo "4. Update backend/resources/Config.toml with your API keys"
echo ""

echo "✅ Setup completed successfully!"
echo ""
echo "🚀 Next steps:"
echo "1. Configure your API keys in backend/resources/Config.toml"
echo "2. Set up the database: mysql -u root -p < database/schema.sql"
echo "3. Run the application: ./scripts/start.sh"
echo ""
echo "📚 For detailed instructions, see docs/setup.md"