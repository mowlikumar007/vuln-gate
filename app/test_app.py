from app import app


def test_health_endpoint():
    client = app.test_client()
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json()["status"] == "ok"


def test_index_page():
    client = app.test_client()
    resp = client.get("/")
    assert resp.status_code == 200
    assert b"Container Vulnerability Gate" in resp.data
