import os

import requests

BASE_URL = os.getenv("BASE_URL", "http://127.0.0.1:8000")


def test_health():

    r = requests.get(f"{BASE_URL}/health")
    assert r.status_code == 200
