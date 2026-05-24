$base = "C:\Users\sneha\Downloads\_fraud-investigator\fraud-investigator\src\main\java\com\frauddetector\fraud_investigator"

New-Item -ItemType Directory -Force -Path "$base\auth"
New-Item -ItemType Directory -Force -Path "$base\config"
New-Item -ItemType Directory -Force -Path "$base\user"
New-Item -ItemType Directory -Force -Path "$base\claim"
New-Item -ItemType Directory -Force -Path "$base\integration"

Set-Content "$base\user\UserEntity.java" 'package com.frauddetector.fraud_investigator.user;
import jakarta.persistence.*;
import lombok.Data;
@Data
@Entity
@Table(name = "users")
public class UserEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(unique = true, nullable = false)
    private String username;
    @Column(nullable = false)
    private String password;
    @Column(nullable = false)
    private String role;
}'

Set-Content "$base\user\UserRepository.java" 'package com.frauddetector.fraud_investigator.user;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
public interface UserRepository extends JpaRepository<UserEntity, Long> {
    Optional<UserEntity> findByUsername(String username);
}'

Set-Content "$base\auth\AuthRequest.java" 'package com.frauddetector.fraud_investigator.auth;
import lombok.Data;
@Data
public class AuthRequest {
    private String username;
    private String password;
}'

Set-Content "$base\auth\AuthController.java" 'package com.frauddetector.fraud_investigator.auth;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AuthService authService;
    public AuthController(AuthService authService) {
        this.authService = authService;
    }
    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody AuthRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }
    @PostMapping("/login")
    public ResponseEntity<String> login(@RequestBody AuthRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
}'

Set-Content "$base\auth\AuthService.java" 'package com.frauddetector.fraud_investigator.auth;
import com.frauddetector.fraud_investigator.config.JwtUtil;
import com.frauddetector.fraud_investigator.user.UserEntity;
import com.frauddetector.fraud_investigator.user.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
@Service
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    public AuthService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }
    public String register(AuthRequest request) {
        UserEntity user = new UserEntity();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole("INVESTIGATOR");
        userRepository.save(user);
        return "User registered successfully!";
    }
    public String login(AuthRequest request) {
        UserEntity user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword()))
            throw new RuntimeException("Invalid password");
        return jwtUtil.generateToken(user.getUsername());
    }
}'

Set-Content "$base\config\JwtUtil.java" 'package com.frauddetector.fraud_investigator.config;
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
}'

Set-Content "$base\config\JwtFilter.java" 'package com.frauddetector.fraud_investigator.config;
import com.frauddetector.fraud_investigator.user.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;
import java.util.ArrayList;
@Component
public class JwtFilter extends OncePerRequestFilter {
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;
    public JwtFilter(JwtUtil jwtUtil, UserRepository userRepository) {
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
    }
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);
            if (jwtUtil.validateToken(token)) {
                String username = jwtUtil.extractUsername(token);
                SecurityContextHolder.getContext().setAuthentication(
                    new UsernamePasswordAuthenticationToken(username, null, new ArrayList<>()));
            }
        }
        filterChain.doFilter(request, response);
    }
}'

Set-Content "$base\config\SecurityConfig.java" 'package com.frauddetector.fraud_investigator.config;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
@Configuration
public class SecurityConfig {
    private final JwtFilter jwtFilter;
    public SecurityConfig(JwtFilter jwtFilter) { this.jwtFilter = jwtFilter; }
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http.csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**", "/h2-console/**").permitAll()
                .anyRequest().authenticated())
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .headers(h -> h.frameOptions(f -> f.disable()))
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }
    @Bean
    public PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(); }
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}'

Set-Content "$base\claim\ClaimEntity.java" 'package com.frauddetector.fraud_investigator.claim;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
@Data
@Entity
@Table(name = "claims")
public class ClaimEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String claimantName;
    private String accidentPhotoPath;
    private String policeReportPath;
    private String repairBillPath;
    private Integer fraudScore;
    private String riskLevel;
    @Column(length = 1000)
    private String reasons;
    private LocalDateTime submittedAt;
    @PrePersist
    public void prePersist() { submittedAt = LocalDateTime.now(); }
}'

Set-Content "$base\claim\ClaimRepository.java" 'package com.frauddetector.fraud_investigator.claim;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface ClaimRepository extends JpaRepository<ClaimEntity, Long> {
    List<ClaimEntity> findByRiskLevel(String riskLevel);
}'

Set-Content "$base\claim\ClaimDTO.java" 'package com.frauddetector.fraud_investigator.claim;
import lombok.Data;
@Data
public class ClaimDTO {
    private Long id;
    private String claimantName;
    private Integer fraudScore;
    private String riskLevel;
    private String reasons;
    private String submittedAt;
}'

Set-Content "$base\claim\ClaimService.java" 'package com.frauddetector.fraud_investigator.claim;
import com.frauddetector.fraud_investigator.integration.PythonServiceClient;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
@Service
public class ClaimService {
    private final ClaimRepository claimRepository;
    private final PythonServiceClient pythonServiceClient;
    private final String UPLOAD_DIR = "uploads/";
    public ClaimService(ClaimRepository claimRepository, PythonServiceClient pythonServiceClient) {
        this.claimRepository = claimRepository;
        this.pythonServiceClient = pythonServiceClient;
    }
    public ClaimEntity submitClaim(String claimantName, MultipartFile photo, MultipartFile policeReport, MultipartFile repairBill) throws Exception {
        new File(UPLOAD_DIR).mkdirs();
        Map<String, Object> aiResult = pythonServiceClient.analyze(photo, policeReport, repairBill);
        ClaimEntity claim = new ClaimEntity();
        claim.setClaimantName(claimantName);
        claim.setAccidentPhotoPath(saveFile(photo));
        claim.setPoliceReportPath(saveFile(policeReport));
        claim.setRepairBillPath(saveFile(repairBill));
        claim.setFraudScore((Integer) aiResult.get("fraud_score"));
        claim.setRiskLevel((String) aiResult.get("risk_level"));
        claim.setReasons(aiResult.get("reasons").toString());
        return claimRepository.save(claim);
    }
    public List<ClaimEntity> getAllClaims() { return claimRepository.findAll(); }
    public ClaimEntity getClaimById(Long id) {
        return claimRepository.findById(id).orElseThrow(() -> new RuntimeException("Claim not found"));
    }
    private String saveFile(MultipartFile file) throws Exception {
        Path path = Paths.get(UPLOAD_DIR + file.getOriginalFilename());
        Files.write(path, file.getBytes());
        return path.toString();
    }
}'

Set-Content "$base\claim\ClaimController.java" 'package com.frauddetector.fraud_investigator.claim;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
@RestController
@RequestMapping("/api/claims")
public class ClaimController {
    private final ClaimService claimService;
    public ClaimController(ClaimService claimService) { this.claimService = claimService; }
    @PostMapping("/submit")
    public ResponseEntity<ClaimEntity> submitClaim(
            @RequestParam("claimantName") String claimantName,
            @RequestParam("photo") MultipartFile photo,
            @RequestParam("policeReport") MultipartFile policeReport,
            @RequestParam("repairBill") MultipartFile repairBill) throws Exception {
        return ResponseEntity.ok(claimService.submitClaim(claimantName, photo, policeReport, repairBill));
    }
    @GetMapping("/all")
    public ResponseEntity<List<ClaimEntity>> getAllClaims() {
        return ResponseEntity.ok(claimService.getAllClaims());
    }
    @GetMapping("/{id}")
    public ResponseEntity<ClaimEntity> getClaimById(@PathVariable Long id) {
        return ResponseEntity.ok(claimService.getClaimById(id));
    }
}'

Set-Content "$base\integration\PythonServiceClient.java" 'package com.frauddetector.fraud_investigator.integration;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import java.util.HashMap;
import java.util.Map;
@Component
public class PythonServiceClient {
    private final RestTemplate restTemplate = new RestTemplate();
    private final String AI_SERVICE_URL = "http://localhost:5000/analyze";
    public Map<String, Object> analyze(MultipartFile photo, MultipartFile policeReport, MultipartFile repairBill) {
        try {
            MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("photo", photo.getResource());
            body.add("police_report", policeReport.getResource());
            body.add("repair_bill", repairBill.getResource());
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);
            ResponseEntity<Map> response = restTemplate.postForEntity(AI_SERVICE_URL,
                new HttpEntity<>(body, headers), Map.class);
            return response.getBody();
        } catch (Exception e) {
            Map<String, Object> mock = new HashMap<>();
            mock.put("fraud_score", 85);
            mock.put("risk_level", "HIGH");
            mock.put("reasons", "Mock - Python not connected");
            return mock;
        }
    }
}'

Write-Host "All files created successfully!"