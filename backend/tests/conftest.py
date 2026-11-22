import secrets

import pytest
from fastapi.testclient import TestClient


@pytest.fixture(scope="session")
def client(tmp_path_factory):
    database = tmp_path_factory.mktemp("smartlab") / "test.sqlite3"
    with pytest.MonkeyPatch.context() as patch:
        patch.setenv("SMARTLAB_DB_URL", "sqlite:///" + database.as_posix())
        patch.setenv("SMARTLAB_JWT_SECRET", secrets.token_urlsafe(48))
        from app.core.database import engine
        from app.main import app

        with TestClient(app) as test_client:
            yield test_client
        engine.dispose()
