#!/bin/bash

# Script Bash pour démarrer tous les microservices WillBank
# Usage: ./start-all-services.sh [mysql]

PROFILE=${1:-default}

echo "========================================"
echo "  WillBank Microservices Launcher"
echo "========================================"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fonction pour démarrer un service
start_service() {
    local service_name=$1
    local service_path=$2
    local port=$3
    local profile=$4
    
    echo -e "${YELLOW}Démarrage de $service_name sur le port $port...${NC}"
    
    cd "$service_path" || exit
    
    if [ "$profile" != "default" ] && [ "$profile" != "" ]; then
        gnome-terminal --title="$service_name" -- bash -c "./mvnw spring-boot:run -Dspring-boot.run.profiles=$profile; exec bash" &
    else
        gnome-terminal --title="$service_name" -- bash -c "./mvnw spring-boot:run; exec bash" &
    fi
    
    cd - > /dev/null || exit
    sleep 2
}

# Vérifier Java
echo -e "${CYAN}Vérification de Java...${NC}"
if command -v java &> /dev/null; then
    java_version=$(java -version 2>&1 | head -n 1)
    echo -e "${GREEN}✓ Java détecté: $java_version${NC}"
else
    echo -e "${RED}✗ Java n'est pas installé ou n'est pas dans le PATH${NC}"
    exit 1
fi

echo ""

# Vérifier Maven Wrapper
echo -e "${CYAN}Vérification de Maven...${NC}"
if [ -f "Client_service/mvnw" ]; then
    echo -e "${GREEN}✓ Maven Wrapper détecté${NC}"
else
    echo -e "${RED}✗ Maven Wrapper non trouvé${NC}"
    exit 1
fi

echo ""

# Vérifier MySQL si profil mysql
if [ "$PROFILE" == "mysql" ]; then
    echo -e "${CYAN}Vérification de MySQL...${NC}"
    if command -v mysql &> /dev/null; then
        if mysql -u willbank_user -pWillBank2024! -e "USE willbank_db; SELECT 1;" &> /dev/null; then
            echo -e "${GREEN}✓ MySQL connecté et base de données willbank_db accessible${NC}"
        else
            echo -e "${RED}✗ Impossible de se connecter à MySQL${NC}"
            echo -e "${YELLOW}Assurez-vous que MySQL est démarré et que la base de données est créée${NC}"
            echo -e "${YELLOW}Voir: database/README.md${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠ MySQL non détecté dans le PATH${NC}"
        echo -e "${YELLOW}Assurez-vous que MySQL est installé et démarré${NC}"
    fi
    echo ""
fi

echo -e "${CYAN}Démarrage des services avec le profil: $PROFILE${NC}"
echo ""

# Obtenir le chemin absolu du répertoire courant
CURRENT_PATH=$(pwd)

# Démarrer Eureka Server en premier
start_service "Eureka Server" "$CURRENT_PATH/Eureka-Service/Eureka-Service" 8761

echo -e "${YELLOW}Attente du démarrage d'Eureka Server (30 secondes)...${NC}"
sleep 30

# Démarrer les autres services
start_service "Client Service" "$CURRENT_PATH/Client_service" 8081 "$PROFILE"
sleep 5

start_service "Account Service" "$CURRENT_PATH/account_service" 8082 "$PROFILE"
sleep 5

start_service "Transaction Service" "$CURRENT_PATH/transaction_service" 8083 "$PROFILE"
sleep 5

start_service "Notification Service" "$CURRENT_PATH/Notification-service/Notification-service" 8084

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Tous les services sont en cours de démarrage!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${CYAN}URLs des services:${NC}"
echo "  - Eureka Dashboard:    http://localhost:8761"
echo "  - Client Service:      http://localhost:8081/swagger-ui.html"
echo "  - Account Service:     http://localhost:8082/swagger-ui.html"
echo "  - Transaction Service: http://localhost:8083/swagger-ui.html"
echo "  - Notification Service: http://localhost:8084/actuator/health"
echo ""
echo -e "${YELLOW}Attendez environ 1-2 minutes pour que tous les services soient complètement démarrés.${NC}"
echo ""
echo -e "${YELLOW}Pour arrêter les services, fermez toutes les fenêtres de terminal ouvertes.${NC}"
echo ""

# Ouvrir Eureka Dashboard
if command -v xdg-open &> /dev/null; then
    xdg-open "http://localhost:8761"
elif command -v open &> /dev/null; then
    open "http://localhost:8761"
fi
