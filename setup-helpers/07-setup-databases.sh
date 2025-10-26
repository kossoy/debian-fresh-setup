#!/bin/bash
# =============================================================================
# Database Setup Script - Docker-based
# =============================================================================
# Sets up PostgreSQL, MySQL, MongoDB, and Redis via Docker
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🗄️  Database Setup (Docker-based)${NC}"
echo "===================================="
echo ""

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    echo "Install Docker first:"
    echo "  ./setup-helpers/04-install-docker.sh"
    exit 1
fi

# Check if Docker is running
if ! docker ps >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running or you don't have permission${NC}"
    echo "Try:"
    echo "  sudo systemctl start docker"
    echo "  newgrp docker"
    exit 1
fi

echo -e "${GREEN}✅ Docker is available${NC}"
echo ""

# Create docker network for databases
NETWORK_NAME="dev-network"
if ! docker network ls | grep -q "$NETWORK_NAME"; then
    echo -e "${BLUE}📡 Creating Docker network: $NETWORK_NAME${NC}"
    docker network create "$NETWORK_NAME"
else
    echo -e "${GREEN}✅ Network '$NETWORK_NAME' already exists${NC}"
fi

echo ""

# Database credentials (change these for production!)
POSTGRES_PASSWORD="devpassword"
MYSQL_PASSWORD="devpassword"
MONGO_PASSWORD="devpassword"

# Interactive mode or auto-install
AUTO_INSTALL=false
if [[ "$1" == "--auto" ]]; then
    AUTO_INSTALL=true
    INSTALL_POSTGRES=true
    INSTALL_MYSQL=true
    INSTALL_MONGO=true
    INSTALL_REDIS=true
fi

if [[ "$AUTO_INSTALL" == "false" ]]; then
    echo "Choose databases to install:"
    echo ""

    read -p "Install PostgreSQL? (y/n): " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_POSTGRES=true || INSTALL_POSTGRES=false

    read -p "Install MySQL? (y/n): " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_MYSQL=true || INSTALL_MYSQL=false

    read -p "Install MongoDB? (y/n): " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_MONGO=true || INSTALL_MONGO=false

    read -p "Install Redis? (y/n): " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]] && INSTALL_REDIS=true || INSTALL_REDIS=false

    echo ""
fi

# PostgreSQL
if [[ "$INSTALL_POSTGRES" == "true" ]]; then
    echo -e "${BLUE}🐘 Setting up PostgreSQL...${NC}"

    if docker ps -a | grep -q "dev-postgres"; then
        echo -e "${YELLOW}⚠️  Container 'dev-postgres' already exists${NC}"
        read -p "Remove and recreate? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker rm -f dev-postgres
        else
            echo "Skipping PostgreSQL"
            INSTALL_POSTGRES=false
        fi
    fi

    if [[ "$INSTALL_POSTGRES" == "true" ]]; then
        docker run -d \
            --name dev-postgres \
            --network "$NETWORK_NAME" \
            -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
            -e POSTGRES_USER=postgres \
            -e POSTGRES_DB=devdb \
            -p 5432:5432 \
            -v postgres-data:/var/lib/postgresql/data \
            --restart unless-stopped \
            postgres:16-alpine

        echo -e "${GREEN}✅ PostgreSQL started${NC}"
        echo "   Host: localhost"
        echo "   Port: 5432"
        echo "   User: postgres"
        echo "   Password: $POSTGRES_PASSWORD"
        echo "   Database: devdb"
        echo "   Connection: postgresql://postgres:$POSTGRES_PASSWORD@localhost:5432/devdb"
    fi
    echo ""
fi

# MySQL
if [[ "$INSTALL_MYSQL" == "true" ]]; then
    echo -e "${BLUE}🐬 Setting up MySQL...${NC}"

    if docker ps -a | grep -q "dev-mysql"; then
        echo -e "${YELLOW}⚠️  Container 'dev-mysql' already exists${NC}"
        read -p "Remove and recreate? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker rm -f dev-mysql
        else
            echo "Skipping MySQL"
            INSTALL_MYSQL=false
        fi
    fi

    if [[ "$INSTALL_MYSQL" == "true" ]]; then
        docker run -d \
            --name dev-mysql \
            --network "$NETWORK_NAME" \
            -e MYSQL_ROOT_PASSWORD="$MYSQL_PASSWORD" \
            -e MYSQL_DATABASE=devdb \
            -p 3306:3306 \
            -v mysql-data:/var/lib/mysql \
            --restart unless-stopped \
            mysql:8.0

        echo -e "${GREEN}✅ MySQL started${NC}"
        echo "   Host: localhost"
        echo "   Port: 3306"
        echo "   User: root"
        echo "   Password: $MYSQL_PASSWORD"
        echo "   Database: devdb"
        echo "   Connection: mysql://root:$MYSQL_PASSWORD@localhost:3306/devdb"
    fi
    echo ""
fi

# MongoDB
if [[ "$INSTALL_MONGO" == "true" ]]; then
    echo -e "${BLUE}🍃 Setting up MongoDB...${NC}"

    if docker ps -a | grep -q "dev-mongo"; then
        echo -e "${YELLOW}⚠️  Container 'dev-mongo' already exists${NC}"
        read -p "Remove and recreate? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker rm -f dev-mongo
        else
            echo "Skipping MongoDB"
            INSTALL_MONGO=false
        fi
    fi

    if [[ "$INSTALL_MONGO" == "true" ]]; then
        docker run -d \
            --name dev-mongo \
            --network "$NETWORK_NAME" \
            -e MONGO_INITDB_ROOT_USERNAME=admin \
            -e MONGO_INITDB_ROOT_PASSWORD="$MONGO_PASSWORD" \
            -p 27017:27017 \
            -v mongo-data:/data/db \
            --restart unless-stopped \
            mongo:7

        echo -e "${GREEN}✅ MongoDB started${NC}"
        echo "   Host: localhost"
        echo "   Port: 27017"
        echo "   User: admin"
        echo "   Password: $MONGO_PASSWORD"
        echo "   Connection: mongodb://admin:$MONGO_PASSWORD@localhost:27017"
    fi
    echo ""
fi

# Redis
if [[ "$INSTALL_REDIS" == "true" ]]; then
    echo -e "${BLUE}🔴 Setting up Redis...${NC}"

    if docker ps -a | grep -q "dev-redis"; then
        echo -e "${YELLOW}⚠️  Container 'dev-redis' already exists${NC}"
        read -p "Remove and recreate? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker rm -f dev-redis
        else
            echo "Skipping Redis"
            INSTALL_REDIS=false
        fi
    fi

    if [[ "$INSTALL_REDIS" == "true" ]]; then
        docker run -d \
            --name dev-redis \
            --network "$NETWORK_NAME" \
            -p 6379:6379 \
            -v redis-data:/data \
            --restart unless-stopped \
            redis:7-alpine \
            redis-server --appendonly yes

        echo -e "${GREEN}✅ Redis started${NC}"
        echo "   Host: localhost"
        echo "   Port: 6379"
        echo "   Connection: redis://localhost:6379"
    fi
    echo ""
fi

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Database Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo "Running containers:"
docker ps --filter "name=dev-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "Useful commands:"
echo "  docker ps                          # List running containers"
echo "  docker logs dev-postgres           # View PostgreSQL logs"
echo "  docker exec -it dev-postgres psql -U postgres  # Connect to PostgreSQL"
echo "  docker exec -it dev-mysql mysql -uroot -p$MYSQL_PASSWORD  # Connect to MySQL"
echo "  docker exec -it dev-mongo mongosh -u admin -p $MONGO_PASSWORD  # Connect to MongoDB"
echo "  docker exec -it dev-redis redis-cli  # Connect to Redis"
echo ""
echo "  docker stop dev-postgres           # Stop database"
echo "  docker start dev-postgres          # Start database"
echo "  docker rm -f dev-postgres          # Remove database (keeps data)"
echo ""
echo "Data persistence:"
echo "  Data is stored in Docker volumes and persists across container restarts"
echo "  To remove data: docker volume rm postgres-data mysql-data mongo-data redis-data"
echo ""

# Create helper script
mkdir -p ~/work/scripts
cat > ~/work/scripts/db-manage.sh << 'DBEOF'
#!/bin/bash
# Database management helper

case "$1" in
    start)
        echo "Starting all databases..."
        docker start dev-postgres dev-mysql dev-mongo dev-redis 2>/dev/null
        docker ps --filter "name=dev-"
        ;;
    stop)
        echo "Stopping all databases..."
        docker stop dev-postgres dev-mysql dev-mongo dev-redis 2>/dev/null
        ;;
    status)
        docker ps --filter "name=dev-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    logs)
        if [[ -z "$2" ]]; then
            echo "Usage: db-manage.sh logs <postgres|mysql|mongo|redis>"
            exit 1
        fi
        docker logs -f "dev-$2"
        ;;
    connect)
        case "$2" in
            postgres|pg)
                docker exec -it dev-postgres psql -U postgres
                ;;
            mysql)
                docker exec -it dev-mysql mysql -uroot -pdevpassword
                ;;
            mongo)
                docker exec -it dev-mongo mongosh -u admin -p devpassword
                ;;
            redis)
                docker exec -it dev-redis redis-cli
                ;;
            *)
                echo "Usage: db-manage.sh connect <postgres|mysql|mongo|redis>"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Database Management Helper"
        echo ""
        echo "Usage: db-manage.sh <command> [args]"
        echo ""
        echo "Commands:"
        echo "  start              Start all databases"
        echo "  stop               Stop all databases"
        echo "  status             Show database status"
        echo "  logs <db>          Show database logs"
        echo "  connect <db>       Connect to database"
        echo ""
        echo "Databases: postgres, mysql, mongo, redis"
        ;;
esac
DBEOF

chmod +x ~/work/scripts/db-manage.sh

echo -e "${GREEN}✅ Helper script created: ~/work/scripts/db-manage.sh${NC}"
echo ""
echo "Quick database management:"
echo "  db-manage.sh start             # Start all databases"
echo "  db-manage.sh stop              # Stop all databases"
echo "  db-manage.sh status            # Show status"
echo "  db-manage.sh connect postgres  # Connect to PostgreSQL"
echo ""
