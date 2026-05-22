Automated Insurance Claim Fraud Investigator

AI-Powered System to Detect Fraudulent Insurance Claims in Real-Time

Problem Statement:
Insurance companies lose millions every year due to fraudulent claims. 
This system automatically analyzes documents, images and patterns to 
flag suspicious claims before payout.

System Workflow
User Uploads Files → OCR Text Extraction → Feature Analysis → 
AI Fraud Prediction → Risk Score Output

Tech Stack
Backend        : Java 17, Spring Boot 3.2
AI Service     : Python, Flask
OCR            : Tesseract OCR
Image Analysis : OpenCV
ML Model       : Scikit-learn (Random Forest)
Database       : PostgreSQL
Frontend       : React.js
Deployment     : AWS EC2 + Docker

Features
- Upload accident photos, police reports, repair bills
- OCR extracts text from PDFs and images
- Detects duplicate or edited images
- ML model predicts fraud probability
- Real-time fraud score with risk level
- JWT secured REST APIs
- Investigator dashboard

Output Example
{
  "fraud_score": 92,
  "risk_level": "HIGH",
  "reasons": [
    "Duplicate image detected",
    "Repair cost mismatch",
    "Location inconsistency"
  ]
}

