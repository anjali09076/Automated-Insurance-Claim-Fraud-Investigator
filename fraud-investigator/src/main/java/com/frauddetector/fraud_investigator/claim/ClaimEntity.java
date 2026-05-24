package com.frauddetector.fraud_investigator.claim;
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
}
