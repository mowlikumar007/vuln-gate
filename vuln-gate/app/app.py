"""Tiny demo web app used as the scan target for the container vulnerability gate."""
import os
from flask import Flask, jsonify

app = Flask(__name__)

BUILD_VARIANT = os.environ.get("BUILD_VARIANT", "unknown")
GIT_SHA = os.environ.get("GIT_SHA", "local")
APP_VERSION = os.environ.get("APP_VERSION", "1.0.0")


@app.route("/")
def index():
    return f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>Vulnerability Gate Demo</title>
<style>
 body{{font-family:system-ui,sans-serif;max-width:640px;margin:60px auto;padding:0 16px;color:#1a1a1a}}
 .card{{border:1px solid #ddd;border-radius:12px;padding:24px}}
 .tag{{display:inline-block;padding:2px 10px;border-radius:999px;background:#e6f4ea;color:#137333;font-size:14px}}
 code{{background:#f3f3f3;padding:2px 6px;border-radius:4px}}
</style></head><body><div class="card">
<h1>Container Vulnerability Gate</h1>
<p><span class="tag">deployed: passed security scan</span></p>
<p>Image variant: <code>{BUILD_VARIANT}</code></p>
<p>App version: <code>{APP_VERSION}</code></p>
<p>Commit: <code>{GIT_SHA[:7]}</code></p>
<p>Health endpoint: <code>/health</code></p>
</div></body></html>"""


@app.route("/health")
def health():
    return jsonify(status="ok", variant=BUILD_VARIANT, version=APP_VERSION, commit=GIT_SHA)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "5000")))
