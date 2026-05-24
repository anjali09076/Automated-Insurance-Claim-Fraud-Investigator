package com.frauddetector.fraud_investigator.config;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;
import java.security.Key;
import java.util.Date;
@Component
public class JwtUtil {
    private final String SECRET = "fraudinvestigator_secret_key_2024_secure";
    private final long EXPIRATION = 86400000;
    private Key getKey() { return Keys.hmacShaKeyFor(SECRET.getBytes()); }
    public String generateToken(String username) {
        return Jwts.builder().setSubject(username).setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION))
                .signWith(getKey()).compact();
    }
    public String extractUsername(String token) {
        return Jwts.parserBuilder().setSigningKey(getKey()).build()
                .parseClaimsJws(token).getBody().getSubject();
    }
    public boolean validateToken(String token) {
        try { Jwts.parserBuilder().setSigningKey(getKey()).build().parseClaimsJws(token); return true; }
        catch (Exception e) { return false; }
    }
}
