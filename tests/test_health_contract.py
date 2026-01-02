import os

import requests

BASE_URL = os.getenv("BASE_URL", "http://127.0.0.1:8000")


def test_health_contract():
    r = requests.get(f"{BASE_URL}/health")

    # Status
    assert r.status_code == 200

    # Headers
    assert r.headers["Content-Type"].startswith("application/json")

    # Body
    data = r.json()
    assert isinstance(data, dict)

    # Contract
    assert data["status"] == "ok"
    assert "version" in data
    assert isinstance(data["version"], str)
    expected_version = os.getenv("APP_VERSION")
    assert data["version"] == expected_version
