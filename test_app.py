import pytest

from app import create_app, __version__


@pytest.fixture
def client():
    app = create_app()
    app.config["TESTING"] = True
    return app.test_client()


def test_home_page_loads(client):
    resp = client.get("/")
    assert resp.status_code == 200
    assert b"Deployed with Azure DevOps" in resp.data


def test_health_endpoint(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.get_json() == {"status": "UP", "version": __version__}


def test_info_endpoint_uses_env(client, monkeypatch):
    monkeypatch.setenv("APP_ENV", "dev")
    monkeypatch.setenv("BUILD_ID", "42")
    data = client.get("/api/info").get_json()
    assert data["environment"] == "dev"
    assert data["build_id"] == "42"
