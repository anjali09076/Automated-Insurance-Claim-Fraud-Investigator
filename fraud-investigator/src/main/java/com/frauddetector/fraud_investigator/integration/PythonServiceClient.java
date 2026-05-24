package com.frauddetector.fraud_investigator.integration;
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
}
