package com.frauddetector.fraud_investigator.claim;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface ClaimRepository extends JpaRepository<ClaimEntity, Long> {
    List<ClaimEntity> findByRiskLevel(String riskLevel);
}
