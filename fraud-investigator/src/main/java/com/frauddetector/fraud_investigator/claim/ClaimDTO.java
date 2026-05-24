package com.frauddetector.fraud_investigator.claim;
import lombok.Data;
@Data
public class ClaimDTO {
    private Long id;
    private String claimantName;
    private Integer fraudScore;
    private String riskLevel;
    private String reasons;
    private String submittedAt;
}
