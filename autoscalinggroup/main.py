from typing import Union

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware


origins = [
    "*"
    ]
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/market")
def read_hello():
    return {"message": "THis is market service deployed on ec2 instance"}