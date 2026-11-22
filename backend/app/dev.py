"""Start the loopback development server for the duration of the Qt session."""

import argparse
import socket
import subprocess
import threading
import time
from pathlib import Path

import uvicorn


def run(client: str, port: int) -> int:
    executable = Path(client).resolve(strict=True)
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", port))
        address = f"http://127.0.0.1:{listener.getsockname()[1]}"
        config = uvicorn.Config("app.main:app", host="127.0.0.1", port=port)
        server = uvicorn.Server(config)
        worker = threading.Thread(target=server.run, kwargs={"sockets": [listener]}, daemon=True)
        worker.start()
        desktop = None
        try:
            deadline = time.monotonic() + 15
            while not server.started:
                if not worker.is_alive() or time.monotonic() >= deadline:
                    raise RuntimeError("The local API did not become ready.")
                time.sleep(0.1)
            desktop = subprocess.Popen([str(executable), "--api-url", address], cwd=executable.parent)
            return desktop.wait()
        finally:
            if desktop is not None and desktop.poll() is None:
                desktop.terminate()
                desktop.wait()
            server.should_exit = True
            worker.join(timeout=10)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--client", required=True)
    parser.add_argument("--port", type=int, default=8765)
    args = parser.parse_args()
    raise SystemExit(run(args.client, args.port))
