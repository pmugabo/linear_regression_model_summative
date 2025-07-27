from fastapi import FastAPI
from pydantic import BaseModel, Field
from fastapi.middleware.cors import CORSMiddleware
import joblib
import math
import numpy as np
import uvicorn
import os

# Initialize the FastAPI app
app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the model
model = joblib.load("best_model.pkl")

# Optional: Load scaler if saved
# scaler = joblib.load("scaler.pkl")

# Define sample data based on your selected top 5 features
@app.get("/sample-data")
async def sample_data():
    sample = {
        "hdi_rank": 58,
        "le_1990": 61.5,
        "le_2000": 64.2,
        "le_2010": 67.9,
        "le_2020": 70.1
    }
    return {"sample_input_data": sample}

# Root endpoint
@app.get("/")
async def root():
    return {"message": "✅ Life Expectancy Predictor API is running. Use /predict to send data or /sample-data to see input format."}

# Define expected input schema
class ModelInput(BaseModel):
    hdi_rank: float = Field(..., ge=1, le=200)
    le_1990: float = Field(..., ge=30, le=90)
    le_2000: float = Field(..., ge=30, le=90)
    le_2010: float = Field(..., ge=30, le=90)
    le_2020: float = Field(..., ge=30, le=90)

# Prediction endpoint
@app.post("/predict")
async def predict(input_data: ModelInput):
    # Extract features in expected order
    features = np.array([[
        input_data.hdi_rank,
        input_data.le_1990,
        input_data.le_2000,
        input_data.le_2010,
        input_data.le_2020
    ]])

    # Optional: scale features
    # features = scaler.transform(features)

    # Predict
    prediction = model.predict(features)

    return {"predicted_life_expectancy_2021": round(prediction[0], 2)}

# For running via python life_expectancy_api.py
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("Life_api:app", host="0.0.0.0", port=port)
