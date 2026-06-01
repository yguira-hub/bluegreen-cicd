from flask import Flask, jsonify
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
import os

app = Flask(__name__)
REQUEST_COUNT = Counter('app_requests_total', 'Total requests', ['method', 'endpoint'])

APP_VERSION = os.getenv("APP_VERSION", "v1")
APP_COLOR   = os.getenv("APP_COLOR", "blue")
APP_PORT    = int(os.getenv("APP_PORT", 5000))

@app.route("/")
def home():
    REQUEST_COUNT.labels(method="GET", endpoint="/").inc()
    return f"""<html><body style="background:{APP_COLOR};color:white;font-family:sans-serif;text-align:center;padding:80px">
      <h1>Version {APP_VERSION}</h1><p>Environment: <strong>{APP_COLOR.upper()}</strong></p>
    </body></html>"""

@app.route("/health")
def health():
    REQUEST_COUNT.labels(method="GET", endpoint="/health").inc()
    return jsonify({"status": "ok", "version": APP_VERSION, "color": APP_COLOR})

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=APP_PORT)
