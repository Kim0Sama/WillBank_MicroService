# Configuration des Ports - WillBank Microservices

## Architecture des Ports

| Service | Port | URL | Description |
|---------|------|-----|-------------|
| **Eureka Server** | 8761 | http://localhost:8761 | Service Discovery |
| **Gateway Service** | 8080 | http://localhost:8080 | API Gateway (Point d'entrée unique) |
| **Account Service** | 8081 | http://localhost:8081 | Gestion des comptes |
| **Transaction Service** | 8082 | http://localhost:8082 | Gestion des transactions |
| **Client Service** | 8084 | http://localhost:8084 | Gestion des clients + Auth |

## Ordre de Démarrage

**IMPORTANT**: Les services doivent démarrer dans cet ordre :

1. **Eureka Server** (8761) - Attendre 30 secondes
2. **Client Service** (8084) - Attendre 15 secondes
3. **Account Service** (8081) - Attendre 15 secondes
4. **Transaction Service** (8082) - Attendre 15 secondes
5. **Gateway Service** (8080) - Attendre 15 secondes

## Scripts de Gestion

### Démarrage Automatique
```powershell
.\start-services-clean.ps1
```
Ce script :
- Tue tous les processus existants sur les ports
- Démarre les services dans le bon ordre
- Attend entre chaque démarrage

### Arrêt de Tous les Services
```powershell
.\stop-services.ps1
```

### Vérification des Ports
```powershell
netstat -ano | findstr "8080 8081 8082 8084 8761"
```

### Tuer un Processus Spécifique
```powershell
# Trouver le PID
netstat -ano | findstr ":8081"

# Tuer le processus
taskkill /F /PID <PID>
```

## Accès via Gateway

Tous les appels API doivent passer par le Gateway (port 8080) :

```
http://localhost:8080/api/clients/**    → Client Service (8084)
http://localhost:8080/api/accounts/**   → Account Service (8081)
http://localhost:8080/api/transactions/** → Transaction Service (8082)
```

## Endpoints Importants

### Eureka Dashboard
- http://localhost:8761

### Gateway Health Check
- http://localhost:8080/actuator/health

### Service Health Checks
- http://localhost:8081/actuator/health (Account)
- http://localhost:8082/actuator/health (Transaction)
- http://localhost:8084/actuator/health (Client)

### Authentication
- POST http://localhost:8080/api/clients/auth/login

## Troubleshooting

### Port Already in Use
```powershell
# Utiliser le script d'arrêt
.\stop-services.ps1

# Ou manuellement
netstat -ano | findstr ":<PORT>"
taskkill /F /PID <PID>
```

### Service ne démarre pas
1. Vérifier que MySQL est démarré
2. Vérifier que Eureka est démarré en premier
3. Vérifier les logs dans la console du service
4. Vérifier la configuration dans application.yaml

### Eureka ne voit pas les services
- Attendre 30-60 secondes après le démarrage
- Vérifier que `eureka.client.service-url.defaultZone` pointe vers http://localhost:8761/eureka/
- Redémarrer le service problématique

## Configuration MySQL

Chaque service utilise sa propre base de données :

| Service | Database | User | Port |
|---------|----------|------|------|
| Client Service | willbank_client_db | client_service_user | 3306 |
| Account Service | willbank_account_db | account_service_user | 3306 |
| Transaction Service | willbank_transaction_db | transaction_service_user | 3306 |
