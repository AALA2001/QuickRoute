#!/bin/bash

# Sentra Development Startup Script

echo "🚀 Starting Sentra Cyber Threat Monitoring System..."

# Check if MySQL is running
if ! pgrep -x "mysqld" > /dev/null; then
    echo "❌ MySQL is not running. Please start MySQL first:"
    echo "   sudo systemctl start mysql"
    exit 1
fi

# Check if database exists
DB_EXISTS=$(mysql -u root -p -e "SHOW DATABASES LIKE 'sentra_db';" 2>/dev/null | grep sentra_db)
if [ -z "$DB_EXISTS" ]; then
    echo "⚠️  Database 'sentra_db' not found. Please create it first:"
    echo "   mysql -u root -p < database/schema.sql"
    exit 1
fi

# Function to start backend
start_backend() {
    echo "🔧 Starting Ballerina backend..."
    cd backend
    bal run &
    BACKEND_PID=$!
    echo "Backend started with PID: $BACKEND_PID"
    cd ..
}

# Function to start frontend
start_frontend() {
    echo "🎨 Starting React frontend..."
    cd frontend
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing npm dependencies..."
        npm install
    fi
    npm start &
    FRONTEND_PID=$!
    echo "Frontend started with PID: $FRONTEND_PID"
    cd ..
}

# Start both services
start_backend
sleep 5  # Give backend time to start
start_frontend

echo ""
echo "✅ Sentra is starting up!"
echo "📱 Frontend: http://localhost:3000"
echo "🔗 Backend API: http://localhost:8080"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for both processes
wait $BACKEND_PID $FRONTEND_PID