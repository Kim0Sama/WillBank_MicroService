# 🏦 WillBank - Démarrage Rapide

## ⚡ Configuration en 3 Commandes

### 1️⃣ Configurer la Base de Données + Authentification

```cmd
cd database
EXECUTE_ME.bat
EXECUTE-AUTH-SETUP.bat
```

### 2️⃣ Démarrer les Services Backend

```powershell
.\start-services-clean.ps1
```

### 3️⃣ Démarrer le Frontend

```powershell
cd Frontend
npm install
npm start
```

## 🎯 Accès Rapide

- **Frontend** : http://localhost:4200
- **Eureka Dashboard** : http://localhost:8761
- **API Gateway** : http://localhost:8080

## 🔐 Credentials de Test

### Client Normal
- Email: `jean.dupont@example.com`
- Password: `password123`

### Administrateur
- Email: `admin@willbank.com`
- Password: `password123`

## 📖 Documentation Complète

Voir [SETUP_COMPLETE_GUIDE.md](SETUP_COMPLETE_GUIDE.md) pour le guide détaillé.

## 🐛 Problèmes ?

1. **Port déjà utilisé** : `.\stop-services.ps1` puis redémarrer
2. **Erreur de connexion** : Vérifier que `EXECUTE-AUTH-SETUP.bat` a été exécuté
3. **Service ne démarre pas** : Vérifier que MySQL est démarré

Voir [AUTH_TROUBLESHOOTING.md](AUTH_TROUBLESHOOTING.md) pour plus de détails.

---

**Temps total de configuration : ~5 minutes**
