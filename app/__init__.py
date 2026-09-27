"""DevOps Demo App - a tiny Flask app used to demo Azure DevOps end to end."""
import os
import socket
from datetime import datetime, timezone

from flask import Flask, jsonify, render_template

__version__ = "1.0.0"


def create_app():
    app = Flask(__name__)

    def info():
        return {
            "app": "DevOps Demo App",
            "version": __version__,
            "environment": os.getenv("APP_ENV", "local"),
            "build_id": os.getenv("BUILD_ID", "local-build"),
            "host": socket.gethostname(),
            "time_utc": datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S"),
        }

    @app.route("/")
    def home():
        return render_template("index.html", info=info())

    @app.route("/health")
    def health():
        return jsonify(status="UP", version=__version__), 200

    @app.route("/api/info")
    def api_info():
        return jsonify(info())

    return app


app = create_app()

if __name__ == "__main__":
    port = int(os.getenv("PORT", "8000"))
    app.run(host="0.0.0.0", port=port)
