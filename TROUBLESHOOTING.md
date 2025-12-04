# Guide de dépannage WillBank

## 🔧 Problèmes courants et solutions

### 1. Erreur : "Access denied for user" (MySQL)

**Symptôme :**
```
Access denied for user 'client_service_user'@'localhost' (using password: YES)
```

**Cause :**
Les utilisateurs MySQL pour les microservices n'ont pas été créés.

**Solution :**

#### Option 1 : Script PowerShell (Recommandé)
```powershell
cd database
.\create-mysql-users.ps1
```

#### Option 2 : Script Batch
```cmd
cd database
create-mysql-users.bat
```

#### Option 3 : MySQL Workbench
1. Ouvrir MySQL Workbench
2. Se connecter en tant que root
3. Ouvrir le fichier `database/create-databases.sql`
4. Exécuter le script complet (⚡ Execute)

#### Option 4 : Ligne de commande
```bash
mysql -u root -p < database/create-databases.sql
```

**Vérification :**
```sql
-- Vérifier les utilisateurs créés
SELECT User, Host FROM mysql.user WHERE User LIKE '%service%';

-- Vérifier les bases de données
SHOW DATABASES LIKE 'willbank%';
```

**Identifiants créés :**
- `client_service_user` / `ClientService2024!` → `willbank_client_db`
- `account_service_user` / `AccountService2024!` → `willbank_account_db`
- `transaction_service_user` / `TransactionService2024!` → `willbank_transaction_db`

📖 **Voir aussi :** `database/FIX_ACCESS_DENIED.md`

---

### 2. Erreur : "Violation de clé primaire" au démarrage

**Symptôme :**
```
JdbcSQLIntegrityConstraintViolationException: Violation d'index unique ou clé primaire
PRIMARY KEY ON PUBLIC.CLIENTS(ID)
```

**Cause :**
Le fichier `data.sql` essaie d'insérer des données de test qui existent déjà dans la base de données persistante.

**Solution :**
Désactiver l'exécution automatique de `data.sql` dans `application.yaml` :

```yaml
spring:
  sql:
    init:
      mode: never  # Changer de 'always' à 'never'
```

**Alternative :** Supprimer la base de données existante
```bash
# Supprimer les fichiers de base de données
rm -rf Client_service/data/*
rm -rf account_service/data/*
rm -rf transaction_service/data/*
```

---

### 3. Erreur : "Port already in use"

**Symptôme :**
```
Web server failed to start. Port 8084 was already in use.
```

**Cause :**
Un autre processus utilise déjà le port.

**Solution :**

#### Windows
```powershell
# Trouver le processus
netstat -ano | findstr :8084

# Tuer le processus (remplacer PID par le numéro trouvé)
taskkill /PID <PID> /F
```

#### Linux/macOS
```bash
# Trouver et tuer le processus
lsof -ti:8084 | xargs kill -9
```

---

### 4. Erreur : "Unable to open database file"

**Symptôme :**
```
Unable to read file 'client-service-db.mv.db'
(Unknown FileSystemError)
```

**Cause :**
Vous essayez d'ouvrir le fichier binaire `.mv.db` dans un éditeur de texte.

**Solution :**
Utiliser la console H2 web :
1. Ouvrir : http://localhost:8084/h2-console
2. JDBC URL : `jdbc:h2:file:./data/client-service-db`
3. Username : `sa`
4. Password : (vide)

---

### 5. Erreur : "Database may be already in use"

**Symptôme :**
```
Database may be already in use: "Locked by another process"
```

**Cause :**
La base de données est verrouillée par un autre processus.

**Solution :**
```bash
# Arrêter tous les services
# Supprimer les fichiers de verrouillage
rm Client_service/data/*.lock
rm account_service/data/*.lock
rm transaction_service/data/*.lock

# Redémarrer les services
```

---

### 6. Service ne s'enregistre pas dans Eureka

**Symptôme :**
Le service démarre mais n'apparaît pas dans le dashboard Eureka.

**Cause :**
- Eureka Server n'est pas démarré
- Mauvaise configuration de l'URL Eureka
- Problème réseau

**Solution :**
1. Vérifier qu'Eureka Server est démarré : http://localhost:8761
2. Vérifier la configuration dans `application.yaml` :
```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```
3. Attendre 30 secondes (délai d'enregistrement)

---

### 7. Erreur : "Unable to find main class"

**Symptôme :**
```
Unable to find a single main class from the following candidates
```

**Cause :**
Plusieurs classes principales dans le projet.

**Solution :**
Supprimer les anciennes classes de test :
```bash
# Trouver les classes en double
find . -name "*Application.java" -path "*/test/*"

# Supprimer les anciennes classes
rm -rf src/test/java/com/example/
rm -rf src/main/java/com/example/
```

---

### 8. Base de données corrompue

**Symptôme :**
Erreurs aléatoires lors de l'accès aux données.

**Solution :**
Réinitialiser la base de données :
```bash
# Arrêter le service
# Supprimer les fichiers de base de données
rm -rf Client_service/data/*

# Redémarrer le service
# Les tables seront recréées automatiquement
```

---

### 9. Données de test manquantes

**Symptôme :**
La base de données est vide après le premier démarrage.

**Solution :**

#### Option 1 : Réactiver temporairement data.sql
```yaml
spring:
  sql:
    init:
      mode: always
```
Démarrer une fois, puis remettre à `never`.

#### Option 2 : Insérer via l'API
```bash
curl -X POST http://localhost:8084/api/clients \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jean",
    "lastName": "Dupont",
    "email": "jean.dupont@example.com",
    "phoneNumber": "+33612345678",
    "address": "123 Rue de la République",
    "city": "Paris",
    "postalCode": "75001",
    "country": "France",
    "dateOfBirth": "1985-03-15",
    "nationalId": "1850315123456"
  }'
```

#### Option 3 : Insérer via console H2
```sql
INSERT INTO clients (first_name, last_name, email, phone_number, address, city, postal_code, country, date_of_birth, national_id, status, kyc_status) 
VALUES ('Jean', 'Dupont', 'jean.dupont@example.com', '+33612345678', '123 Rue de la République', 'Paris', '75001', 'France', '1985-03-15', '1850315123456', 'ACTIVE', 'VERIFIED');
```

---

### 10. Erreur de compilation Maven

**Symptôme :**
```
BUILD FAILURE
Compilation failure
```

**Solution :**
```bash
# Nettoyer et recompiler
cd Client_service
.\mvnw.cmd clean compile

# Si ça ne fonctionne pas, supprimer le cache Maven
rm -rf ~/.m2/repository
.\mvnw.cmd clean install
```

---

### 11. Swagger UI ne s'affiche pas

**Symptôme :**
404 Not Found sur `/swagger-ui.html`

**Solution :**
1. Vérifier que le service est démarré
2. Essayer l'URL alternative : `/swagger-ui/index.html`
3. Vérifier la configuration dans `pom.xml` :
```xml
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-ui</artifactId>
    <version>1.7.0</version>
</dependency>
```

---

## 🔍 Commandes de diagnostic

### Vérifier l'état des services
```powershell
# Windows
$ports = @(8761, 8081, 8082, 8083, 8084)
foreach ($port in $ports) {
    try {
        $response = Invoke-WebRequest "http://localhost:$port/actuator/health" -UseBasicParsing -TimeoutSec 2
        Write-Host "Port $port : UP"
    } catch {
        Write-Host "Port $port : DOWN"
    }
}
```

### Vérifier les processus en cours
```powershell
# Windows
Get-Process | Where-Object {$_.ProcessName -like "*java*"}

# Linux/macOS
ps aux | grep java
```

### Vérifier les ports utilisés
```powershell
# Windows
netstat -ano | findstr "8081 8082 8083 8084"

# Linux/macOS
netstat -an | grep "8081\|8082\|8083\|8084"
```

### Vérifier les logs
```bash
# Les logs s'affichent dans le terminal où le service est démarré
# Pour rediriger vers un fichier :
.\mvnw.cmd spring-boot:run > logs/client-service.log 2>&1
```

---

## 📚 Ressources utiles

- **Eureka Dashboard** : http://localhost:8761
- **Client Service Swagger** : http://localhost:8084/swagger-ui.html
- **Client Service H2 Console** : http://localhost:8084/h2-console
- **Account Service Swagger** : http://localhost:8081/swagger-ui.html
- **Transaction Service Swagger** : http://localhost:8082/swagger-ui.html

---

## 🆘 Réinitialisation complète

Si rien ne fonctionne, réinitialisation complète :

```bash
# 1. Arrêter tous les services (Ctrl+C dans chaque terminal)

# 2. Supprimer toutes les bases de données
rm -rf */data/*
rm -rf */*/data/*

# 3. Nettoyer les builds
cd Client_service && .\mvnw.cmd clean && cd ..
cd account_service && .\mvnw.cmd clean && cd ..
cd transaction_service && .\mvnw.cmd clean && cd ..

# 4. Recompiler
cd Client_service && .\mvnw.cmd compile && cd ..
cd account_service && .\mvnw.cmd compile && cd ..
cd transaction_service && .\mvnw.cmd compile && cd ..

# 5. Redémarrer dans l'ordre
# - Eureka Server
# - Account Service
# - Transaction Service
# - Notification Service
# - Client Service
```

---

**Dernière mise à jour :** 3 Décembre 2024
