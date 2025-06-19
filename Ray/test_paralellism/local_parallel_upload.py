import os
import shutil
import ray
import traceback
import socket

CHUNK_SOURCE_DIR = "/mnt/shared/chunks"
CHUNK_UPLOAD_DIR = "/mnt/shared/uploaded_chunks"


@ray.remote(num_cpus=1, scheduling_strategy="SPREAD")
def fake_upload(chunk_path):
    node = socket.gethostname()
    print(f"📦 Uploading {chunk_path} from node: {node}")
    try:
        os.makedirs(CHUNK_UPLOAD_DIR, exist_ok=True)
        target_path = os.path.join(CHUNK_UPLOAD_DIR, os.path.basename(chunk_path))
        shutil.copyfile(chunk_path, target_path)
        print(ray.available_resources())
        return f"✅ Copied: {chunk_path}"
    except Exception as e:
        return f"❌ Failed: {chunk_path} | {repr(e)}\n{traceback.format_exc()}"


@ray.remote(num_cpus=1, scheduling_strategy="SPREAD")
def prepare_chunk(i):
    os.makedirs(CHUNK_SOURCE_DIR, exist_ok=True)
    chunk_path = os.path.join(CHUNK_SOURCE_DIR, f"chunk_{i}.zip")
    with open(chunk_path, "wb") as f:
        f.write(os.urandom(102400 * 102400))  # 1024MB dummy chunk
    return f"🧱 Created: {chunk_path}"

def ensure_target_dir():
    os.makedirs(CHUNK_UPLOAD_DIR, exist_ok=True)

def prepare_chunks_parallel(n_chunks=6):
    os.makedirs(CHUNK_SOURCE_DIR, exist_ok=True)
    futures = [prepare_chunk.remote(i) for i in range(n_chunks)]
    results = ray.get(futures)
    for r in results:
        print(r)

def run():
    prepare_chunks_parallel()
    ensure_target_dir()
    print("Started RUN")
    chunks = [
        os.path.join(CHUNK_SOURCE_DIR, fname)
        for fname in os.listdir(CHUNK_SOURCE_DIR)
        if fname.endswith(".zip")
    ]

    futures = [fake_upload.remote(chunk) for chunk in chunks]
    print("Got futures")
    results = ray.get(futures)

    for r in results:
        print(r)

if __name__ == "__main__":
    ray.init()  # will be auto-connected in Ray Job
    print([node["NodeManagerAddress"] for node in ray.nodes()])
    run()
