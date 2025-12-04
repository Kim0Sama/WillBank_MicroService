# Client Service - WillBank

Service de gestion des clients pour la plateforme bancaire WillBank.

## Description

Le Client Service gère toutes les opérations liées aux clients de la banque, incluant :
- Création et gestion des profils clients
- Vérification KYC (Know Your Customer)
- Gestion des statuts clients
- Mise à jour des informations personnelles

## Technologies

- Java 21
- Spring Boot 2.7.18
- Spring Cloud (Eureka Client)
- Spring Data JPA
- H2 Database (en mémoire)
- Lombok
- SpringDoc OpenAPI (Swagger)

## Configuration

### Port
Le service s'exécute sur le port **8081**

### Base de données
- Type : H2 (en mémoire)
- URL : `jdbc:h2:mem:clientdb`
- Console H2 : http://localhost:8081/h2-console

### Eureka
Le service s'enregistre auprès d'Eureka sur : http://localhost:8761/eureka/

## API Endpoints

### Clients

#### Créer un client
```
POST /api/clients
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+33612345678",
  "address": "123 Rue de la Paix",
  "city": "Paris",
  "postalCode": "75001",
  "country": "France",
  "dateOfBirth": "1990-01-15",
  "nationalId": "1234567890123"
}
```

#### Récupérer un client par ID
```
GET /api/clients/{id}
```

#### Récupérer un client par email
```
GET /api/clients/email/{email}
```

#### Récupérer tous les clients
```
GET /api/clients
```

#### Récupérer les clients par statut
```
GET /api/clients/status/{status}
```
Statuts possibles : `PENDING`, `ACTIVE`, `SUSPENDED`, `CLOSED`

#### Récupérer les clients par statut KYC
```
GET /api/clients/kyc-status/{kycStatus}
```
Statuts KYC possibles : `NOT_VERIFIED`, `PENDING_VERIFICATION`, `VERIFIED`, `REJECTED`

#### Mettre à jour un client
```
PUT /api/clients/{id}
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+33612345678",
  "address": "456 Avenue des Champs",
  "city": "Paris",
  "postalCode": "75008",
  "country": "France"
}
```

#### Mettre à jour le statut d'un client
```
PATCH /api/clients/{id}/status?status=ACTIVE
```

#### Mettre à jour le statut KYC
```
PATCH /api/clients/{id}/kyc
Content-Type: application/json

{
  "kycStatus": "VERIFIED",
  "notes": "Documents vérifiés avec succès"
}
```

#### Supprimer un client
```
DELETE /api/clients/{id}
```

## Modèle de données

### Client
- `id` : Identifiant unique (Long)
- `firstName` : Prénom (String, obligatoire)
- `lastName` : Nom (String, obligatoire)
- `email` : Email (String, unique, obligatoire)
- `phoneNumber` : Numéro de téléphone (String, obligatoire)
- `address` : Adresse (String)
- `city` : Ville (String)
- `postalCode` : Code postal (String)
- `country` : Pays (String)
- `dateOfBirth` : Date de naissance (LocalDate)
- `nationalId` : Numéro d'identification nationale (String, unique)
- `status` : Statut du client (Enum)
- `kycStatus` : Statut KYC (Enum)
- `createdAt` : Date de création (LocalDateTime)
- `updatedAt` : Date de mise à jour (LocalDateTime)

### Statuts Client
- `PENDING` : En attente de validation
- `ACTIVE` : Actif
- `SUSPENDED` : Suspendu
- `CLOSED` : Fermé

### Statuts KYC
- `NOT_VERIFIED` : Non vérifié
- `PENDING_VERIFICATION` : En cours de vérification
- `VERIFIED` : Vérifié
- `REJECTED` : Rejeté

## Documentation API

La documentation Swagger est accessible à :
- Swagger UI : http://localhost:8081/swagger-ui.html
- API Docs : http://localhost:8081/api-docs

## Démarrage

### Prérequis
- Java 21
- Maven 3.6+
- Eureka Server en cours d'exécution sur le port 8761

### Lancer le service

#### Avec Maven
```bash
cd Client_service
mvnw spring-boot:run
```

#### Avec Maven (Windows)
```bash
cd Client_service
mvnw.cmd spring-boot:run
```

### Build
```bash
mvnw clean package
```

## Gestion des erreurs

Le service utilise un gestionnaire d'exceptions global qui retourne des réponses structurées :

### Erreur 404 - Client non trouvé
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 404,
  "error": "Not Found",
  "message": "Client not found with ID: 123",
  "path": "/api/clients/123"
}
```

### Erreur 409 - Conflit (client existe déjà)
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 409,
  "error": "Conflict",
  "message": "Client with email john@example.com already exists",
  "path": "/api/clients"
}
```

### Erreur 400 - Validation
```json
{
  "timestamp": "2024-01-15T10:30:00",
  "status": 400,
  "error": "Validation Failed",
  "errors": {
    "email": "Email must be valid",
    "firstName": "First name is required"
  },
  "path": "/api/clients"
}
```

## Monitoring

Les endpoints Actuator sont disponibles :
- Health : http://localhost:8081/actuator/health
- Info : http://localhost:8081/actuator/info
- Metrics : http://localhost:8081/actuator/metrics
