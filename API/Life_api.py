from fastapi import FastAPI
from pydantic import BaseModel, Field
from typing import Annotated
from fastapi.middleware.cors import CORSMiddleware
import numpy as np
import pickle

app = FastAPI(title="Life Expectancy Prediction API")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model
with open("best_model.pkl", "rb") as f:
    model = pickle.load(f)

# Input schema
class LifeExpectancyInput(BaseModel):
    hdi_rank_2021: Annotated[int, Field(ge=1, le=189, description="HDI Rank (2021)")]
    le_1990: Annotated[float, Field(ge=0, le=100, description="Life Expectancy 1990")]
    le_2000: Annotated[float, Field(ge=0, le=100, description="Life Expectancy 2000")]
    le_2010: Annotated[float, Field(ge=0, le=100, description="Life Expectancy 2010")]
    le_2020: Annotated[float, Field(ge=0, le=100, description="Life Expectancy 2020")]

@app.post("/predict")
def predict(data: LifeExpectancyInput):
    features = np.array([
        [
            data.hdi_rank_2021,
            data.le_1990,
            data.le_2000,
            data.le_2010,
            data.le_2020
        ]
    ])
    pred = model.predict(features)[0]
    return {"predicted_life_expectancy_2021": round(float(pred), 2)}
