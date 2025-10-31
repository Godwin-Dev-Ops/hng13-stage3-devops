import os
import time
import re
import requests

LOG_FILE = "/var/log/nginx-real/access.log"
SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL")

# Simple regex to capture status code from Nginx access logs
STATUS_REGEX = re.compile(r'"\s(\d{3})\s')

def send_slack_message(text):
    """Post formatted text message to Slack."""
    if not SLACK_WEBHOOK_URL:
        print("⚠️ No Slack webhook URL set. Skipping message.")
        return
    try:
        payload = {"text": text}
        r = requests.post(SLACK_WEBHOOK_URL, json=payload)
        print(f"[Slack] Sent → {r.status_code}: {r.text}")
    except Exception as e:
        print(f"Slack error: {e}")

def tail_log():
    """Continuously watch the log file for new lines."""
    print("[Watcher] 🔍 Watching Nginx access log for 4xx/5xx errors...")
    while not os.path.exists(LOG_FILE):
        print(f"Waiting for log file {LOG_FILE}...")
        time.sleep(2)

    with open(LOG_FILE, "r") as f:
        f.seek(0, 2)  # Go to end of file
        while True:
            line = f.readline()
            if not line:
                time.sleep(0.5)
                continue

            match = STATUS_REGEX.search(line)
            if match:
                code = int(match.group(1))
                if 400 <= code < 500:
                    send_slack_message(f"⚠️ *Client error* detected: `{code}` → {line.strip()}")
                elif 500 <= code < 600:
                    send_slack_message(f"🚨 *Server error* detected: `{code}` → {line.strip()}")

if __name__ == "__main__":
    print("[Watcher] ✅ Started successfully and connected to Slack.")
    tail_log()

