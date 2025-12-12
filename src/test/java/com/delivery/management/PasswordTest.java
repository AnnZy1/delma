package com.delivery.management;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

@SpringBootTest
public class PasswordTest {

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Test
    public void testPassword() {
        String rawPassword = "123456";
        String encodedPassword = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pQ/O";
        
        System.out.println("Raw password: " + rawPassword);
        System.out.println("Encoded password: " + encodedPassword);
        System.out.println("Match: " + passwordEncoder.matches(rawPassword, encodedPassword));
        
        // Also test encoding a new password
        String newEncoded = passwordEncoder.encode(rawPassword);
        System.out.println("New encoded: " + newEncoded);
        System.out.println("New match: " + passwordEncoder.matches(rawPassword, newEncoded));
    }
}