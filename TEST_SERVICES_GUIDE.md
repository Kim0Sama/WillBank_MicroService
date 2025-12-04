# Guide de Test des Services WillBank

## Étape 1 : Vérifier les données dans les bases de données

Exécute ce script pour voir les données existantes :
```cmd
database\CHECK-ALL-DATA.bat
```

## Étape 2 : Insérer les données de test si nécessaire

Si les bases de données sont vides, exécute :
```cmd
database\ENSURE-TEST-DATA.bat
```

## Étape 3 : Vérifier que tous les services sont démarrés

Assure-toi que tous les services sont en cours d'exécution :
- Eureka Server (port 8761)
- Gateway Service (port 8080)
- Client Service (port 8084)
- Account Service (port 8082)
- Transaction Service (port 8083)

Tu peux les démarrer avec :
```cmd
start-all-services.bat
```

## Étape 4 : Vérifier Eureka Dashboard

Ouvre http://localhost:8761 et vérifie que tous les services sont enregistrés :
- CLIENT-SERVICE
- ACCOUNT-SERVICE
- TRANSACTION-SERVICE
- GATEWAY-SERVICE

## Étape 5 : Tester les APIs via le Gateway

### Test 1 : Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"marie.martin@example.com\",\"password\":\"password123\"}"
```

Copie le token JWT retourné.

### Test 2 : Récupérer les comptes d'un client
```bash
curl -X GET http://localhost:8080/api/accounts/customer/1 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Test 3 : Récupérer les transactions d'un compte
```bash
curl -X GET http://localhost:8080/api/transactions/account/ACC1001000001 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Étape 6 : Tester le Frontend

1. Démarre le frontend Angular :
```cmd
cd Frontend
npm start
```

2. Ouvre http://localhost:4200

3. Connecte-toi avec :
   - Email: marie.martin@example.com
   - Password: password123

4. Vérifie que :
   - Le dashboard affiche les comptes
   - Les transactions récentes s'affichent
   - La page Accounts montre tous les comptes
   - La page Transactions permet de faire des dépôts/retraits/transferts

## Données de Test Disponibles

### Clients
- ID 1: marie.martin@example.com (2 comptes)
- ID 2: pierre.bernard@example.com (2 comptes)
- ID 3: sophie.dubois@example.com (1 compte)
- ID 4: luc.moreau@example.com (1 compte)
- ID 5: admin@willbank.com (1 compte) - ADMIN

Tous avec le mot de passe : **password123**

### Comptes
- ACC1001000001 : Checking - 5000 EUR (Client 1)
- ACC1001000002 : Savings - 15000 EUR (Client 1)
- ACC1002000001 : Checking - 3500 EUR (Client 2)
- ACC1002000002 : Business - 25000 EUR (Client 2)
- ACC1003000001 : Checking - 7200 EUR (Client 3)
- ACC1004000001 : Savings - 12000 EUR (Client 4)
- ACC1005000001 : Checking - 100000 EUR (Admin)

## Dépannage

### Problème : Les comptes ne s'affichent pas
1. Vérifie que Account Service est démarré et enregistré dans Eureka
2. Vérifie les logs du Account Service
3. Teste l'API directement : http://localhost:8082/api/accounts/customer/1

### Problème : Les transactions ne s'affichent pas
1. Vérifie que Transaction Service est démarré et enregistré dans Eureka
2. Vérifie les logs du Transaction Service
3. Teste l'API directement : http://localhost:8083/api/transactions/account/ACC1001000001

### Problème : Erreur 401 Unauthorized
1. Vérifie que le token JWT est valide
2. Vérifie que le AuthenticationFilter du Gateway fonctionne
3. Vérifie les logs du Gateway Service

### Problème : Erreur CORS
1. Vérifie la configuration CORS dans gateway/application.yaml
2. Assure-toi que le frontend tourne sur http://localhost:4200
