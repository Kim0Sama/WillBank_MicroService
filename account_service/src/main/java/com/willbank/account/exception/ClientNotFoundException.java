package com.willbank.account.exception;

/**
 * Exception levée quand un client n'est pas trouvé
 */
public class ClientNotFoundException extends RuntimeException {
    
    public ClientNotFoundException(Long clientId) {
        super("Client not found with ID: " + clientId);
    }
    
    public ClientNotFoundException(String message) {
        super(message);
    }
}
