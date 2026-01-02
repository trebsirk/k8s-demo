import os

from fastapi import FastAPI

app = FastAPI()

APP_VERSION = os.getenv("APP_VERSION", "dev")


@app.get("/")
def root():
    return {"message": "Hello Kubernetes!"}


@app.get("/health")
def health():
    return {"status": "ok", "version": APP_VERSION}


@app.get("/version")
def version():
    return {"version": APP_VERSION}

# Add a pre-deploy env validation step
# Add a /meta endpoint with build info
# Add an integration-test.sh