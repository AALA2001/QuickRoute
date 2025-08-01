# Sentra Deployment Guide

This guide covers deploying Sentra to production environments including cloud platforms, containerization, and CI/CD setup.

## 🚀 Production Deployment Options

### Option 1: Traditional Server Deployment

#### Prerequisites
- Ubuntu 20.04+ or CentOS 8+ server
- 4GB+ RAM, 2+ CPU cores
- MySQL 8.0+ database server
- Domain name with SSL certificate
- Nginx or Apache reverse proxy

#### Step 1: Server Setup
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y nginx mysql-server certbot python3-certbot-nginx

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Ballerina
curl -sSL https://dist.ballerina.io/downloads/swan-lake-latest/ballerina-installer-linux-x64.deb -o ballerina.deb
sudo dpkg -i ballerina.deb
```

#### Step 2: Application Deployment
```bash
# Clone repository
git clone https://github.com/your-org/sentra.git
cd sentra

# Build backend
cd backend
bal build
cd ..

# Build frontend
cd frontend
npm install
npm run build
cd ..

# Set up systemd service for backend
sudo tee /etc/systemd/system/sentra-backend.service << EOF
[Unit]
Description=Sentra Backend Service
After=network.target mysql.service

[Service]
Type=simple
User=sentra
WorkingDirectory=/opt/sentra/backend
ExecStart=/usr/bin/bal run
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
sudo systemctl enable sentra-backend
sudo systemctl start sentra-backend
```

#### Step 3: Nginx Configuration
```nginx
# /etc/nginx/sites-available/sentra
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # Frontend
    location / {
        root /opt/sentra/frontend/build;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:8080/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
```

### Option 2: Docker Deployment

#### Docker Compose Setup
```yaml
# docker-compose.yml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: sentra-mysql
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: sentra_db
      MYSQL_USER: sentra_user
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
      - ./database/schema.sql:/docker-entrypoint-initdb.d/schema.sql
    networks:
      - sentra-network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: sentra-backend
    depends_on:
      - mysql
    environment:
      DB_HOST: mysql
      DB_USER: sentra_user
      DB_PASSWORD: ${DB_PASSWORD}
      DB_NAME: sentra_db
      JWT_SECRET: ${JWT_SECRET}
      HIBP_API_KEY: ${HIBP_API_KEY}
      VT_API_KEY: ${VT_API_KEY}
    networks:
      - sentra-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: sentra-frontend
    depends_on:
      - backend
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./ssl:/etc/ssl/certs
    networks:
      - sentra-network

volumes:
  mysql_data:

networks:
  sentra-network:
    driver: bridge
```

#### Backend Dockerfile
```dockerfile
# backend/Dockerfile
FROM ballerina/ballerina:swan-lake-latest

WORKDIR /app
COPY . .

RUN bal build

EXPOSE 8080

CMD ["bal", "run"]
```

#### Frontend Dockerfile
```dockerfile
# frontend/Dockerfile
FROM node:18-alpine as build

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
```

### Option 3: Kubernetes Deployment

#### Namespace and ConfigMap
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: sentra

---
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sentra-config
  namespace: sentra
data:
  DB_HOST: "mysql-service"
  DB_NAME: "sentra_db"
  DB_USER: "sentra_user"
```

#### MySQL Deployment
```yaml
# k8s/mysql.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql
  namespace: sentra
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: root-password
        - name: MYSQL_DATABASE
          value: "sentra_db"
        - name: MYSQL_USER
          value: "sentra_user"
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: user-password
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pvc

---
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: sentra
spec:
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

#### Backend Deployment
```yaml
# k8s/backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sentra-backend
  namespace: sentra
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sentra-backend
  template:
    metadata:
      labels:
        app: sentra-backend
    spec:
      containers:
      - name: backend
        image: sentra/backend:latest
        ports:
        - containerPort: 8080
        envFrom:
        - configMapRef:
            name: sentra-config
        - secretRef:
            name: sentra-secrets
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: sentra
spec:
  selector:
    app: sentra-backend
  ports:
  - port: 8080
    targetPort: 8080
```

### Option 4: Cloud Platform Deployment

#### AWS ECS with Fargate
```json
{
  "family": "sentra-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::account:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "sentra-backend",
      "image": "your-account.dkr.ecr.region.amazonaws.com/sentra-backend:latest",
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "DB_HOST",
          "value": "sentra.cluster.region.rds.amazonaws.com"
        }
      ],
      "secrets": [
        {
          "name": "DB_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:sentra/db:password::"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/sentra-backend",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

#### Google Cloud Run
```yaml
# cloudbuild.yaml
steps:
  # Build backend
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/sentra-backend', './backend']
  
  # Build frontend
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/sentra-frontend', './frontend']
  
  # Push images
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/sentra-backend']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/sentra-frontend']
  
  # Deploy to Cloud Run
  - name: 'gcr.io/cloud-builders/gcloud'
    args: [
      'run', 'deploy', 'sentra-backend',
      '--image', 'gcr.io/$PROJECT_ID/sentra-backend',
      '--platform', 'managed',
      '--region', 'us-central1',
      '--allow-unauthenticated'
    ]
```

## 🔧 Production Configuration

### Environment Variables
```bash
# Production environment variables
export NODE_ENV=production
export DB_HOST=your-db-host
export DB_USER=sentra_user
export DB_PASSWORD=secure_password
export DB_NAME=sentra_db
export JWT_SECRET=your-super-secure-jwt-secret
export HIBP_API_KEY=your-hibp-api-key
export VT_API_KEY=your-virustotal-api-key
export SMTP_HOST=smtp.your-provider.com
export SMTP_USERNAME=notifications@your-domain.com
export SMTP_PASSWORD=your-smtp-password
```

### Database Optimization
```sql
-- MySQL production optimizations
SET GLOBAL innodb_buffer_pool_size = 2147483648; -- 2GB
SET GLOBAL max_connections = 500;
SET GLOBAL query_cache_size = 268435456; -- 256MB

-- Create indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_reports_status ON threat_reports(status);
CREATE INDEX idx_reports_created ON threat_reports(created_at);
CREATE INDEX idx_notifications_user ON notifications(user_id, status);
```

### SSL/TLS Configuration
```bash
# Generate SSL certificate with Let's Encrypt
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Automatic renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📊 Monitoring and Logging

### Application Monitoring
```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  grafana_data:
```

### Log Management
```yaml
# ELK Stack for logging
elasticsearch:
  image: docker.elastic.co/elasticsearch/elasticsearch:7.9.0
  environment:
    - discovery.type=single-node
    - "ES_JAVA_OPTS=-Xms512m -Xmx512m"

logstash:
  image: docker.elastic.co/logstash/logstash:7.9.0
  volumes:
    - ./logstash/pipeline:/usr/share/logstash/pipeline

kibana:
  image: docker.elastic.co/kibana/kibana:7.9.0
  ports:
    - "5601:5601"
  environment:
    ELASTICSEARCH_HOSTS: http://elasticsearch:9200
```

## 🔒 Security Considerations

### Firewall Configuration
```bash
# UFW firewall setup
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### Security Headers
```nginx
# Additional security headers
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

### Database Security
```sql
-- Remove default accounts
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Create limited user for application
CREATE USER 'sentra_app'@'%' IDENTIFIED BY 'secure_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON sentra_db.* TO 'sentra_app'@'%';
FLUSH PRIVILEGES;
```

## 🚀 CI/CD Pipeline

### GitHub Actions
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '18'
      
      - name: Test Backend
        run: |
          cd backend
          bal test
      
      - name: Test Frontend
        run: |
          cd frontend
          npm ci
          npm test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to server
        uses: appleboy/ssh-action@v0.1.4
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.PRIVATE_KEY }}
          script: |
            cd /opt/sentra
            git pull origin main
            ./scripts/deploy-production.sh
```

## 📈 Scaling Considerations

### Horizontal Scaling
- Use load balancers (HAProxy, AWS ALB)
- Database read replicas
- Redis for session management
- CDN for static assets

### Performance Optimization
- Enable Gzip compression
- Implement API rate limiting
- Use database connection pooling
- Cache frequently accessed data

### Backup Strategy
```bash
#!/bin/bash
# backup.sh
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u root -p sentra_db > backup_${DATE}.sql
aws s3 cp backup_${DATE}.sql s3://sentra-backups/
rm backup_${DATE}.sql
```

This deployment guide provides comprehensive instructions for deploying Sentra in various production environments with proper security, monitoring, and scaling considerations.