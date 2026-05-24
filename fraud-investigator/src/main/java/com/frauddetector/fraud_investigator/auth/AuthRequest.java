package com.frauddetector.fraud_investigator.auth;
import lombok.Data;
@Data
public class AuthRequest {
    private String username;
    private String password;
}
