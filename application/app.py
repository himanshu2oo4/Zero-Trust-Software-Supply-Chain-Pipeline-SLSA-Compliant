from fastapi import FastAPI
import uvicorn
import os

app = FastAPI(title="Payment-Gateway-Service", version="1.0.0")

@app.get("/healthz")          # endpoint for health check
def health_check():
    # Production probes (Kubernetes) hit this to check if the pod is alive
    return {"status": "healthy"}

@app.get("/")
def home():
    return {
        "message": "Welcome to UnderCover Secure Payment API",
        "environment": os.getenv("APP_ENV", "production")
    }
AWS_SECRET_KEY = "AKIAIOSFODNN7EXAMPLE1234567890" # Fake AWS key for testing gitleak 
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)\
    