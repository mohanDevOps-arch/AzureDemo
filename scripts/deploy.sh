#!/usr/bin/env bash
# Deploys the packaged app on THIS machine (the self-hosted agent).
# Usage: deploy.sh <env-name> <port> <path-to-app.zip> <build-id>
set -euo pipefail

ENV_NAME="$1"
PORT="$2"
PACKAGE="$3"
BUILD_ID="${4:-manual}"

TARGET_DIR="$HOME/demo-apps/$ENV_NAME"
PID_FILE="$TARGET_DIR/app.pid"

echo ">>> Deploying build $BUILD_ID to '$ENV_NAME' on port $PORT"

# 1. Stop the old version if it is running
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo ">>> Stopping old process $(cat "$PID_FILE")"
  kill "$(cat "$PID_FILE")" || true
  sleep 2
fi

# 2. Fresh copy of the new version
rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"
python3 -m zipfile -e "$PACKAGE" "$TARGET_DIR"
cd "$TARGET_DIR"

# 3. Install runtime dependencies in an isolated virtualenv
python3 -m venv .venv
.venv/bin/pip install -q --upgrade pip
.venv/bin/pip install -q -r requirements.txt

# 4. Start in the background so it keeps running after the pipeline job ends
#    (unsetting the agent's tracking variable stops the agent from killing it)
env -u VSTS_PROCESS_LOOKUP_ID APP_ENV="$ENV_NAME" BUILD_ID="$BUILD_ID" \
  setsid nohup .venv/bin/gunicorn --bind "0.0.0.0:$PORT" --workers 2 app:app \
  > app.log 2>&1 < /dev/null &
echo $! > "$PID_FILE"

# 5. Smoke test: wait for /health to answer
for i in $(seq 1 15); do
  if python3 -c "import urllib.request,sys; urllib.request.urlopen('http://localhost:$PORT/health', timeout=2)" 2>/dev/null; then
    echo ">>> Health check passed: http://localhost:$PORT"
    exit 0
  fi
  sleep 2
done

echo "!!! Health check failed. Last log lines:"
tail -n 30 app.log
exit 1
