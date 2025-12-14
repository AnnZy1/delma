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
        
        // Test the original hash from the test file
        String testHash = "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iwK8pQ/O";
        System.out.println("Test file hash: " + testHash);
        System.out.println("Test file hash matches '123456': " + passwordEncoder.matches(rawPassword, testHash));
        
        // Test the hash from SQL files
        String sqlHash = "$2a$10$8txnIXzhYL4Pr/X7E1H/2.uGYuRaDWy9yJe.t23Ixl1KDBc16x6o2";
        System.out.println("SQL files hash: " + sqlHash);
        System.out.println("SQL files hash matches '123456': " + passwordEncoder.matches(rawPassword, sqlHash));
        
        // Test the user-provided hash
        String userHash = "$2a$10$mU27E63e3e2hdTr2d1GlyeGpVGQ/h6SfOZh1FYldR865VH7cTLuri";
        System.out.println("User-provided hash: " + userHash);
        System.out.println("User-provided hash matches '123456': " + passwordEncoder.matches(rawPassword, userHash));
        
        // Generate new hash for verification
        String newEncoded = passwordEncoder.encode(rawPassword);
        System.out.println("Newly generated hash: " + newEncoded);
        System.out.println("New hash matches '123456': " + passwordEncoder.matches(rawPassword, newEncoded));
    }
}