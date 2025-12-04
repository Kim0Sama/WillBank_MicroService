-- Données de test pour le service Client

-- Client 1 - Actif et vérifié
INSERT INTO clients (id, first_name, last_name, email, phone_number, address, city, postal_code, country, date_of_birth, national_id, status, kyc_status, created_at, updated_at) 
VALUES (1, 'Jean', 'Dupont', 'jean.dupont@example.com', '+33612345678', '123 Rue de la République', 'Paris', '75001', 'France', '1985-03-15', '1850315123456', 'ACTIVE', 'VERIFIED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Client 2 - En attente de vérification KYC
INSERT INTO clients (id, first_name, last_name, email, phone_number, address, city, postal_code, country, date_of_birth, national_id, status, kyc_status, created_at, updated_at) 
VALUES (2, 'Marie', 'Martin', 'marie.martin@example.com', '+33623456789', '456 Avenue des Champs', 'Lyon', '69001', 'France', '1990-07-22', '1900722234567', 'PENDING', 'PENDING_VERIFICATION', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Client 3 - Actif et vérifié
INSERT INTO clients (id, first_name, last_name, email, phone_number, address, city, postal_code, country, date_of_birth, national_id, status, kyc_status, created_at, updated_at) 
VALUES (3, 'Pierre', 'Bernard', 'pierre.bernard@example.com', '+33634567890', '789 Boulevard Saint-Germain', 'Marseille', '13001', 'France', '1988-11-30', '1881130345678', 'ACTIVE', 'VERIFIED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Client 4 - Suspendu
INSERT INTO clients (id, first_name, last_name, email, phone_number, address, city, postal_code, country, date_of_birth, national_id, status, kyc_status, created_at, updated_at) 
VALUES (4, 'Sophie', 'Dubois', 'sophie.dubois@example.com', '+33645678901', '321 Rue Victor Hugo', 'Toulouse', '31000', 'France', '1992-05-18', '1920518456789', 'SUSPENDED', 'VERIFIED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Client 5 - KYC rejeté
INSERT INTO clients (id, first_name, last_name, email, phone_number, address, city, postal_code, country, date_of_birth, national_id, status, kyc_status, created_at, updated_at) 
VALUES (5, 'Luc', 'Petit', 'luc.petit@example.com', '+33656789012', '654 Place de la Liberté', 'Nice', '06000', 'France', '1995-09-25', '1950925567890', 'PENDING', 'REJECTED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
