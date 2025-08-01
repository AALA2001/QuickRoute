#!/bin/bash

# Sentra API Testing Script

echo "🧪 Testing Sentra API Endpoints..."

API_BASE="http://localhost:8080/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "\n${YELLOW}Testing: $description${NC}"
    echo "Endpoint: $method $endpoint"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "%{http_code}" -X $method "$API_BASE$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    else
        response=$(curl -s -w "%{http_code}" -X $method "$API_BASE$endpoint")
    fi
    
    http_code="${response: -3}"
    body="${response%???}"
    
    if [[ $http_code -ge 200 && $http_code -lt 300 ]]; then
        echo -e "${GREEN}✅ SUCCESS - HTTP $http_code${NC}"
        echo "Response: $body" | jq '.' 2>/dev/null || echo "Response: $body"
    else
        echo -e "${RED}❌ FAILED - HTTP $http_code${NC}"
        echo "Response: $body"
    fi
}

# Check if backend is running
echo "🔍 Checking if backend is running..."
if ! curl -s "$API_BASE/health" > /dev/null; then
    echo -e "${RED}❌ Backend is not running on $API_BASE${NC}"
    echo "Please start the backend first:"
    echo "  cd backend && bal run"
    exit 1
fi

echo -e "${GREEN}✅ Backend is running${NC}"

# Test health endpoint
test_endpoint "GET" "/health" "" "Health Check"

# Test user signup
signup_data='{"email":"test@sentra.com","password":"password123","name":"Test User"}'
test_endpoint "POST" "/signup" "$signup_data" "User Signup"

# Test user login
login_data='{"email":"test@sentra.com","password":"password123"}'
test_endpoint "POST" "/login" "$login_data" "User Login"

# Extract token from login response for authenticated requests
echo -e "\n${YELLOW}Getting authentication token...${NC}"
login_response=$(curl -s -X POST "$API_BASE/login" \
    -H "Content-Type: application/json" \
    -d "$login_data")

token=$(echo "$login_response" | jq -r '.token' 2>/dev/null)

if [ "$token" != "null" ] && [ -n "$token" ]; then
    echo -e "${GREEN}✅ Token obtained${NC}"
    
    # Test authenticated endpoints
    echo -e "\n${YELLOW}Testing authenticated endpoints...${NC}"
    
    # Test user profile
    profile_response=$(curl -s -w "%{http_code}" -X GET "$API_BASE/me" \
        -H "Authorization: Bearer $token")
    
    http_code="${profile_response: -3}"
    body="${profile_response%???}"
    
    if [[ $http_code -ge 200 && $http_code -lt 300 ]]; then
        echo -e "${GREEN}✅ Profile endpoint - HTTP $http_code${NC}"
    else
        echo -e "${RED}❌ Profile endpoint - HTTP $http_code${NC}"
    fi
    
    # Test report submission
    report_data='{"title":"Test Threat Report","description":"This is a test threat report","links":["http://malicious-example.com"]}'
    report_response=$(curl -s -w "%{http_code}" -X POST "$API_BASE/reports" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token" \
        -d "$report_data")
    
    http_code="${report_response: -3}"
    
    if [[ $http_code -ge 200 && $http_code -lt 300 ]]; then
        echo -e "${GREEN}✅ Report submission - HTTP $http_code${NC}"
    else
        echo -e "${RED}❌ Report submission - HTTP $http_code${NC}"
    fi
    
    # Test notifications
    notif_response=$(curl -s -w "%{http_code}" -X GET "$API_BASE/notifications" \
        -H "Authorization: Bearer $token")
    
    http_code="${notif_response: -3}"
    
    if [[ $http_code -ge 200 && $http_code -lt 300 ]]; then
        echo -e "${GREEN}✅ Notifications endpoint - HTTP $http_code${NC}"
    else
        echo -e "${RED}❌ Notifications endpoint - HTTP $http_code${NC}"
    fi
    
else
    echo -e "${RED}❌ Could not obtain authentication token${NC}"
fi

echo -e "\n${YELLOW}🏁 API Testing Complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Open http://localhost:3000 in your browser"
echo "2. Create an account and test the full UI"
echo "3. Submit a threat report and check notifications"
echo "4. Access admin dashboard (if you have admin privileges)"