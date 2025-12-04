# Guide de Configuration de l'Authentification

## 🚀 Configuration Rapide (Recommandé)

### Option 1: Script PowerShell (Recommandé)

```powershell
cd database
.\EXECUTE-AUTH-SETUP.ps1
```

### Option 2: Script Batch

```cmd
cd database
EXECUTE-AUTH-SETUP.bat
```

Ces scripts vont automatiquement :
1. ✅ Ajouter les colonnes `password` et `role` à la table `clients`
2. ✅ Mettre à jour les données existantes
3. ✅ Créer 3 utilisateurs de test

## 👥 Utilisateurs Créés

Après l'exécution du script, vous aurez ces utilisateurs :

| Email | Mot de passe | Rôle | Description |
|-------|--------------|------|-------------|
| jean.dupont@example.com | password123 | CLIENT | Utilisateur normal |
| marie.martin@example.com | password123 | CLIENT | Utilisateur normal |
| admin@willbank.com | password123 | ADMIN | Administrateur |

## 📋 Structure de la Table

Après modification, la table `clients` aura ces colonnes supplémentaires :

```sql
password VARCHAR(255) NOT NULL  -- Hash BCrypt du mot de passe
role VARCHAR(20) NOT NULL       -- 'CLIENT' ou 'ADMIN'
```

## 🔧 Configuration Manuelle (Alternative)

Si les scripts automatiques ne fonctionnent pas, vous pouvez exécuter manuellement :

### 1. Ouvrir MySQL Workbench

### 2. Se connecter à MySQL

- Host: localhost
- Port: 3306
- User: root
- Password: [votre mot de passe root]

### 3. Exécuter le script

```sql
-- Copier-coller le contenu de setup-auth-complete.sql
-- Ou utiliser: File > Run SQL Script > setup-auth-complete.sql
```

## ✅ Vérification

### Vérifier que les colonnes existent

```sql
USE willbank_client_db;
DESCRIBE clients;
```

Vous devriez voir les colonnes `password` et `role`.

### Vérifier les utilisateurs

```sql
SELECT id, first_name, last_name, email, role, status 
FROM clients 
WHERE email IN ('jean.dupont@example.com', 'admin@willbank.com');
```

Vous devriez voir 2 utilisateurs (ou 3 avec Marie Martin).

## 🧪 Test de Connexion

### Via curl

```powershell
curl.exe -X POST http://localhost:8080/api/auth/login `
  -H "Content-Type: application/json" `
  --data "@test-login.json"
```

Contenu de `test-login.json` :
```json
{
  "email": "jean.dupont@example.com",
  "password": "password123"
}
```

### Via le Frontend

1. Démarrer les services : `.\start-services-clean.ps1`
2. Ouvrir le frontend : http://localhost:4200
3. Se connecter avec les credentials ci-dessus

## 🔐 Sécurité

### Hash BCrypt

Tous les mots de passe sont hashés avec BCrypt (force 10) :
- Mot de passe en clair : `password123`
- Hash BCrypt : `$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZRGdjGj/n3.rsS3/r/7HNtBJFgEy2`

### Changer un mot de passe

Pour changer le mot de passe d'un utilisateur :

```sql
-- Générer un nouveau hash sur https://bcrypt-generator.com/
-- Ou utiliser un outil Java/Spring

UPDATE clients 
SET password = '$2a$10$[NOUVEAU_HASH]' 
WHERE email = 'user@example.com';
```

## 🐛 Dépannage

### Erreur: "Column already exists"

C'est normal ! Le script est idempotent et ne créera pas les colonnes si elles existent déjà.

### Erreur: "No enum constant Role."

Cela signifie que la colonne `role` existe mais est vide ou contient une valeur invalide.

**Solution** : Réexécuter le script qui mettra à jour toutes les valeurs.

### Erreur: "Access denied"

Vérifiez que :
- MySQL est démarré : `Get-Service MySQL80`
- Le mot de passe root est correct
- Vous avez les droits sur la base `willbank_client_db`

### La table clients n'existe pas

Vous devez d'abord créer la base de données :

```powershell
cd database
.\setup-mysql.ps1
```

## 📚 Scripts Disponibles

| Script | Description |
|--------|-------------|
| `setup-auth-complete.sql` | Script SQL complet (recommandé) |
| `alter-clients-table.sql` | Modifie uniquement la structure |
| `create-test-user.sql` | Crée uniquement les utilisateurs |
| `EXECUTE-AUTH-SETUP.ps1` | Exécution PowerShell (recommandé) |
| `EXECUTE-AUTH-SETUP.bat` | Exécution Batch |

## 🎯 Prochaines Étapes

Après avoir configuré l'authentification :

1. **Démarrer les services** :
   ```powershell
   cd ..
   .\start-services-clean.ps1
   ```

2. **Vérifier Eureka** : http://localhost:8761

3. **Tester l'API** : http://localhost:8080/api/auth/login

4. **Lancer le Frontend** :
   ```powershell
   cd Frontend
   npm start
   ```

5. **Se connecter** : http://localhost:4200/login
