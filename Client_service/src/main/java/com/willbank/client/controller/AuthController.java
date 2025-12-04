package com.willbank.client.controller;

import com.willbank.client.config.JwtUtil;
import com.willbank.client.dto.LoginRequest;
import com.willbank.client.dto.LoginResponse;
import com.willbank.client.entity.Client;
import com.willbank.client.repository.ClientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private ClientRepository clientRepository;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        System.out.println("=== LOGIN ATTEMPT ===");
        System.out.println("Email: " + request.getEmail());
        
        Optional<Client> clientOpt = clientRepository.findByEmail(request.getEmail());
        
        if (clientOpt.isEmpty()) {
            System.out.println("ERROR: Client not found");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid email or password"));
        }

        Client client = clientOpt.get();
        System.out.println("Client found: " + client.getEmail());
        System.out.println("Password in DB: " + (client.getPassword() != null ? "EXISTS" : "NULL"));
        System.out.println("Role in DB: " + (client.getRole() != null ? client.getRole().name() : "NULL"));

        if (client.getPassword() == null) {
            System.out.println("ERROR: Password is NULL in database");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid email or password"));
        }

        System.out.println("Attempting password match...");
        
        boolean matches = false;
        try {
            matches = passwordEncoder.matches(request.getPassword(), client.getPassword());
            System.out.println("Password match result: " + matches);
        } catch (Exception e) {
            System.out.println("ERROR during password matching: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid email or password"));
        }

        if (!matches) {
            System.out.println("ERROR: Password does not match");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid email or password"));
        }
        
        System.out.println("Password matches!");

        if (client.getStatus().name().equals("SUSPENDED") || client.getStatus().name().equals("CLOSED")) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Account is suspended or closed"));
        }

        String token = jwtUtil.generateToken(client.getId(), client.getEmail(), client.getRole().name());

        LoginResponse response = new LoginResponse(
                token,
                client.getId(),
                client.getEmail(),
                client.getFirstName(),
                client.getLastName(),
                client.getRole().name()
        );

        return ResponseEntity.ok(response);
    }

    @PostMapping("/validate")
    public ResponseEntity<?> validateToken(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("valid", false));
        }

        String token = authHeader.substring(7);
        
        if (jwtUtil.isTokenValid(token)) {
            return ResponseEntity.ok(Map.of(
                    "valid", true,
                    "userId", jwtUtil.getUserIdFromToken(token),
                    "email", jwtUtil.getEmailFromToken(token),
                    "role", jwtUtil.getRoleFromToken(token)
            ));
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("valid", false));
    }
}
