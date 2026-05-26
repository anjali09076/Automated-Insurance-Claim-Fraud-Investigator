import { useState } from 'react'

function App() {
  const [activeTab, setActiveTab] = useState('dashboard')
  const [fraudResult, setFraudResult] = useState(null)
  const [loading, setLoading] = useState(false)
  const [claimantName, setClaimantName] = useState('')
  const [photo, setPhoto] = useState(null)
  const [policeReport, setPoliceReport] = useState(null)
  const [repairBill, setRepairBill] = useState(null)

  const submitClaim = async () => {
    setLoading(true)
    const formData = new FormData()
    formData.append('claimantName', claimantName)
    formData.append('photo', photo)
    formData.append('policeReport', policeReport)
    formData.append('repairBill', repairBill)

    try {
      const response = await fetch('http://localhost:8080/api/claims/submit', {
        method: 'POST',
        body: formData
      })
      const data = await response.json()
      setFraudResult(data)
      setActiveTab('result')
    } catch (error) {
      alert('Error submitting claim!')
    }
    setLoading(false)
  }

  return (
    <div style={{fontFamily:'Arial', maxWidth:'900px', margin:'0 auto', padding:'20px'}}>
      
      {/* Header */}
      <div style={{background:'#1a1a2e', color:'white', padding:'20px', borderRadius:'10px', marginBottom:'20px'}}>
        <h1 style={{margin:0}}>🛡️ Insurance Fraud Investigator</h1>
        <p style={{margin:0, color:'#aaa'}}>AI-Powered Fraud Detection System</p>
      </div>

      {/* Tabs */}
      <div style={{display:'flex', gap:'10px', marginBottom:'20px'}}>
        <button 
          onClick={() => setActiveTab('dashboard')}
          style={{padding:'10px 20px', background: activeTab==='dashboard' ? '#e94560' : '#eee', color: activeTab==='dashboard' ? 'white' : 'black', border:'none', borderRadius:'5px', cursor:'pointer'}}>
          Dashboard
        </button>
        <button 
          onClick={() => setActiveTab('submit')}
          style={{padding:'10px 20px', background: activeTab==='submit' ? '#e94560' : '#eee', color: activeTab==='submit' ? 'white' : 'black', border:'none', borderRadius:'5px', cursor:'pointer'}}>
          Submit Claim
        </button>
        {fraudResult && (
          <button 
            onClick={() => setActiveTab('result')}
            style={{padding:'10px 20px', background: activeTab==='result' ? '#e94560' : '#eee', color: activeTab==='result' ? 'white' : 'black', border:'none', borderRadius:'5px', cursor:'pointer'}}>
            Result
          </button>
        )}
      </div>

      {/* Dashboard Tab */}
      {activeTab === 'dashboard' && (
        <div>
          <div style={{display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap:'15px', marginBottom:'20px'}}>
            <div style={{background:'white', padding:'20px', borderRadius:'10px', boxShadow:'0 2px 10px rgba(0,0,0,0.1)', textAlign:'center'}}>
              <h2 style={{color:'#e94560', margin:0}}>1,245</h2>
              <p style={{color:'#666', margin:0}}>Total Claims</p>
            </div>
            <div style={{background:'white', padding:'20px', borderRadius:'10px', boxShadow:'0 2px 10px rgba(0,0,0,0.1)', textAlign:'center'}}>
              <h2 style={{color:'#e94560', margin:0}}>320</h2>
              <p style={{color:'#666', margin:0}}>High Risk</p>
            </div>
            <div style={{background:'white', padding:'20px', borderRadius:'10px', boxShadow:'0 2px 10px rgba(0,0,0,0.1)', textAlign:'center'}}>
              <h2 style={{color:'#e94560', margin:0}}>210</h2>
              <p style={{color:'#666', margin:0}}>Fraudulent</p>
            </div>
          </div>
          <div style={{background:'white', padding:'20px', borderRadius:'10px', boxShadow:'0 2px 10px rgba(0,0,0,0.1)'}}>
            <h3>How It Works</h3>
            <p>1. Upload accident photos, police report and repair bill</p>
            <p>2. AI analyzes documents using OCR and image analysis</p>
            <p>3. ML model predicts fraud probability</p>
            <p>4. System returns fraud score and risk level</p>
            <button 
              onClick={() => setActiveTab('submit')}
              style={{background:'#e94560', color:'white', border:'none', padding:'10px 20px', borderRadius:'5px', cursor:'pointer'}}>
              Submit New Claim →
            </button>
          </div>
        </div>
      )}

      {/* Submit Claim Tab */}
      {activeTab === 'submit' && (
        <div style={{background:'white', padding:'20px', borderRadius:'10px', boxShadow:'0 2px 10px rgba(0,0,0,0.1)'}}>
          <h2>Submit Insurance Claim</h2>
          
          <div style={{marginBottom:'15px'}}>
            <label>Claimant Name</label>
            <input 
              type="text" 
              value={claimantName}
              onChange={e => setClaimantName(e.target.value)}
              placeholder="Enter full name"
              style={{display:'block', width:'100%', padding:'10px', marginTop:'5px', borderRadius:'5px', border:'1px solid #ddd'}}
            />
          </div>

          <div style={{marginBottom:'15px'}}>
            <label>Accident Photo</label>
            <input 
              type="file" 
              onChange={e => setPhoto(e.target.files[0])}
              style={{display:'block', marginTop:'5px'}}
            />
          </div>

          <div style={{marginBottom:'15px'}}>
            <label>Police Report (PDF)</label>
            <input 
              type="file" 
              onChange={e => setPoliceReport(e.target.files[0])}
              style={{display:'block', marginTop:'5px'}}
            />
          </div>

          <div style={{marginBottom:'15px'}}>
            <label>Repair Bill</label>
            <input 
              type="file" 
              onChange={e => setRepairBill(e.target.files[0])}
              style={{display:'block', marginTop:'5px'}}
            />
          </div>

          <button 
            onClick={submitClaim}
            disabled={loading}
            style={{background:'#e94560', color:'white', border:'none', padding:'12px 30px', borderRadius:'5px', cursor:'pointer', fontSize:'16px'}}>
            {loading ? 'Analyzing...' : 'Analyze Claim 🔍'}
          </button>
        </div>
      )}

      {/* Result Tab */}
      {activeTab === 'result' && fraudResult && (
        <div style={{background:'white', padding:'20px', borderRadius:'10px', boxShadow:'0 2px 10px rgba(0,0,0,0.1)'}}>
          <h2>Fraud Analysis Result</h2>
          
          <div style={{textAlign:'center', padding:'20px', background: fraudResult.riskLevel === 'HIGH' ? '#ffe0e0' : '#e0ffe0', borderRadius:'10px', marginBottom:'20px'}}>
            <h1 style={{color: fraudResult.riskLevel === 'HIGH' ? '#e94560' : 'green', fontSize:'60px', margin:0}}>
              {fraudResult.fraudScore}%
            </h1>
            <h2 style={{color: fraudResult.riskLevel === 'HIGH' ? '#e94560' : 'green'}}>
              {fraudResult.riskLevel} RISK
            </h2>
          </div>

          <div style={{marginBottom:'15px'}}>
            <strong>Claimant:</strong> {fraudResult.claimantName}
          </div>

          <div style={{marginBottom:'15px'}}>
            <strong>Reasons:</strong>
            <p style={{background:'#f5f5f5', padding:'10px', borderRadius:'5px'}}>
              {fraudResult.reasons}
            </p>
          </div>

          <div style={{marginBottom:'15px'}}>
            <strong>Submitted:</strong> {fraudResult.submittedAt}
          </div>

          <button 
            onClick={() => {setActiveTab('submit'); setFraudResult(null)}}
            style={{background:'#1a1a2e', color:'white', border:'none', padding:'10px 20px', borderRadius:'5px', cursor:'pointer'}}>
            Submit Another Claim
          </button>
        </div>
      )}
    </div>
  )
}

export default App