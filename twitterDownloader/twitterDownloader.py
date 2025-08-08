import json
import subprocess
import os
import time


SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_JSON = os.path.join(SCRIPT_DIR, "input.json")
STATUS_JSON = os.path.join(SCRIPT_DIR, "status.json")

YTDLP_PATH = r"C:\Users\ferna\Downloads\yt-dlp.exe"


def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save_json(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def load_status(path):
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            content = f.read().strip()
            if not content:
                return {}
            return json.loads(content)
    return {}


def main():
    items = load_json(INPUT_JSON)
    status = load_status(STATUS_JSON)

    for item in items:
        like = item.get("like", {})
        url = like.get("expandedUrl")

        if not url:
            print("⚠️ Skipping item without expandedUrl")
            continue

        if url in status:
            print(f"🔁 Skipping {url}, already processed.")
            continue

        print(f"📥 Downloading: {url}")
        try:
            result = subprocess.run(
                [YTDLP_PATH, "--cookies-from-browser", "firefox", url],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )

            if result.returncode == 0:
                print(f"✅ Success for {url}")
                status[url] = "downloaded"
            else:
                print(f"❌ Failed for {url}")
                status[url] = "failed"

        except Exception as e:
            print(f"🔥 Error running yt-dlp for {url}: {e}")
            status[url] = "failed"

        save_json(STATUS_JSON, status)
        time.sleep(1)


if __name__ == "__main__":
    main()
