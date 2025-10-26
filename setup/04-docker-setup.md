# Docker & Container Setup - Debian 13

Complete Docker setup for containerized development and deployment.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- sudo access

## 1. Install Docker

### Official Docker Installation

```bash
# Remove old versions if any
sudo apt remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt update
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
sudo docker --version
sudo docker compose version
```

## 2. Post-Installation Setup

### Add User to Docker Group

```bash
# Add your user to the docker group
sudo usermod -aG docker $USER

# Apply the new group membership (logout and login or use)
newgrp docker

# Verify you can run docker without sudo
docker run hello-world
```

### Enable Docker Service

```bash
# Enable Docker to start on boot
sudo systemctl enable docker

# Start Docker service
sudo systemctl start docker

# Check status
sudo systemctl status docker
```

## 3. Docker Compose

Docker Compose is included with Docker installation via plugin. Use `docker compose` (not `docker-compose`).

```bash
# Verify Docker Compose
docker compose version

# For compatibility, create an alias
echo 'alias docker-compose="docker compose"' >> ~/.zsh/config/aliases.zsh
```

## 4. Basic Docker Commands

### Container Management

```bash
# Run a container
docker run -d --name mynginx -p 8080:80 nginx

# List running containers
docker ps

# List all containers
docker ps -a

# Stop a container
docker stop mynginx

# Start a container
docker start mynginx

# Remove a container
docker rm mynginx

# View container logs
docker logs mynginx

# Execute command in running container
docker exec -it mynginx bash
```

### Image Management

```bash
# Pull an image
docker pull nginx

# List images
docker images

# Remove an image
docker rmi nginx

# Build an image
docker build -t myapp:latest .

# Tag an image
docker tag myapp:latest myapp:v1.0
```

### System Management

```bash
# View disk usage
docker system df

# Clean up unused resources
docker system prune

# Clean up everything (careful!)
docker system prune -a

# View Docker info
docker info
```

## 5. Docker Compose Project Template

### Basic Web App with Database

```bash
# Create project directory
mkdir -p ~/work/projects/personal/docker-app
cd ~/work/projects/personal/docker-app

# Create docker-compose.yml
cat > docker-compose.yml << 'COMPOSEEOF'
version: '3.8'

services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - app-network
    restart: unless-stopped

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    networks:
      - app-network
    restart: unless-stopped

networks:
  app-network:
    driver: bridge

volumes:
  postgres-data:
COMPOSEEOF

# Create html directory
mkdir -p html
echo "<h1>Hello from Docker!</h1>" > html/index.html

# Start services
docker compose up -d

# View logs
docker compose logs

# Stop services
docker compose down
```

## 6. Common Docker Compose Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs
docker compose logs -f  # Follow logs

# Restart services
docker compose restart

# View running services
docker compose ps

# Execute command in service
docker compose exec web bash

# Rebuild services
docker compose build

# Pull latest images
docker compose pull
```

## 7. Development Databases with Docker

### PostgreSQL

```bash
# Run PostgreSQL
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=mydb \
  -p 5432:5432 \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:15

# Connect to PostgreSQL
docker exec -it postgres psql -U postgres -d mydb
```

### MySQL

```bash
# Run MySQL
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=mydb \
  -p 3306:3306 \
  -v mysql-data:/var/lib/mysql \
  mysql:8

# Connect to MySQL
docker exec -it mysql mysql -u root -p
```

### MongoDB

```bash
# Run MongoDB
docker run -d \
  --name mongodb \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  -p 27017:27017 \
  -v mongo-data:/data/db \
  mongo:7

# Connect to MongoDB
docker exec -it mongodb mongosh -u admin -p password
```

### Redis

```bash
# Run Redis
docker run -d \
  --name redis \
  -p 6379:6379 \
  -v redis-data:/data \
  redis:7-alpine

# Connect to Redis
docker exec -it redis redis-cli
```

## 8. Dockerfile Best Practices

### Basic Node.js Dockerfile

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Expose port
EXPOSE 3000

# Run application
CMD ["node", "index.js"]
```

### Multi-stage Python Dockerfile

```dockerfile
# Build stage
FROM python:3.11-slim as builder

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.11-slim

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /root/.local /root/.local

# Copy application
COPY . .

# Update PATH
ENV PATH=/root/.local/bin:$PATH

# Run application
CMD ["python", "app.py"]
```

## 9. Docker Networks

```bash
# Create network
docker network create my-network

# Run containers on network
docker run -d --name web --network my-network nginx
docker run -d --name db --network my-network postgres:15

# List networks
docker network ls

# Inspect network
docker network inspect my-network

# Remove network
docker network rm my-network
```

## 10. Docker Volumes

```bash
# Create volume
docker volume create my-data

# Use volume
docker run -d -v my-data:/data nginx

# List volumes
docker volume ls

# Inspect volume
docker volume inspect my-data

# Remove volume
docker volume rm my-data

# Clean up unused volumes
docker volume prune
```

## 11. Troubleshooting

### Permission Denied

```bash
# If you get permission denied
sudo usermod -aG docker $USER
newgrp docker

# Or logout and login again
```

### Port Already in Use

```bash
# Find process using port
sudo ss -tulpn | grep :8080

# Use different port in docker run
docker run -p 8081:80 nginx
```

### Container Won't Start

```bash
# Check logs
docker logs <container-name>

# Check if port is available
sudo ss -tulpn | grep :<port>

# Check Docker status
sudo systemctl status docker
```

### Clean Up Space

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune -a
```

## 12. Docker Desktop Alternative

For GUI management, consider Portainer:

```bash
# Install Portainer
docker volume create portainer_data
docker run -d \
  -p 9000:9000 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

# Access at http://localhost:9000
```

## 13. Security Best Practices

1. **Don't run containers as root**
2. **Use official images when possible**
3. **Keep images updated**
4. **Use specific image tags, not :latest**
5. **Scan images for vulnerabilities**
6. **Don't store secrets in images**
7. **Use Docker secrets or environment files**

## Next Steps

Continue with:
- **[Python Environment](02-python-environment.md)** - Python development
- **[Node.js Environment](03-nodejs-environment.md)** - Node.js development
- **[Kubernetes](05-kubernetes-setup.md)** - Container orchestration

---

**Estimated Time**: 20 minutes  
**Difficulty**: Beginner  
**Last Updated**: October 26, 2025
