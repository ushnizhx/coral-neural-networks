# FastAPI backend — Coral Neural Networks
# Run from: Desktop/coral neural networks/backend/
# Command:  uvicorn app:app --host 0.0.0.0 --port 8000

from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
import torch
import torchvision.transforms as transforms
from torchvision.models import efficientnet_b0
from PIL import Image
from collections import OrderedDict
import json, io, base64, os, zipfile, tempfile
import numpy as np
import torch.nn.functional as F
import cv2

app = FastAPI()

# ── Class names ───────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CLASS_NAMES_PATH = os.path.join(BASE_DIR, "..", "class_names (1).json")
with open(CLASS_NAMES_PATH) as f:
    CLASS_NAMES = json.load(f)
# CLASS_NAMES = ["bleached", "dead", "healthy"]
print(f"Classes: {CLASS_NAMES}")

# ── Load model from extracted zip archive ─────────────────────────────────────
MODEL_FOLDER = os.path.join(BASE_DIR, "..", "best_model")

def reconstruct_and_load(folder_path):
    """best_model/ is a PyTorch zip archive that was extracted to disk.
    We reconstruct the zip in a temp dir so torch.load can read it."""
    tmp = tempfile.mkdtemp()
    archive_path = os.path.join(tmp, "best_model.zip")
    with zipfile.ZipFile(archive_path, "w") as zf:
        for root, dirs, files in os.walk(folder_path):
            # Include hidden directories like .data
            dirs[:] = sorted(dirs)
            for file in files:
                full = os.path.join(root, file)
                rel  = os.path.relpath(full, folder_path)
                zf.write(full, os.path.join("archive", rel))
    state = torch.load(archive_path, map_location="cpu", weights_only=False)
    return state

raw_state = reconstruct_and_load(MODEL_FOLDER)

# Strip "module." prefix (saved with DataParallel on Kaggle GPU)
new_state = OrderedDict()
for k, v in raw_state.items():
    new_key = k.replace("module.", "", 1) if k.startswith("module.") else k
    new_state[new_key] = v

# Build model — standard EfficientNet-B0, classifier head = Linear(1280, 3)
model = efficientnet_b0(weights=None)
model.classifier[1] = torch.nn.Linear(1280, len(CLASS_NAMES))
model.load_state_dict(new_state)
model.eval()
print("Model loaded successfully.")

# ── Transform ─────────────────────────────────────────────────────────────────
TRANSFORM = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
])

# ── Grad-CAM on model.features[8] (last conv block) ──────────────────────────
def generate_gradcam(model, input_tensor, target_idx):
    gradients, activations = [], []

    def fwd(module, inp, out): activations.append(out.detach())
    def bwd(module, gi, go):   gradients.append(go[0].detach())

    target_layer = model.features[8]          # confirmed: last Conv2dNormActivation
    hf = target_layer.register_forward_hook(fwd)
    hb = target_layer.register_full_backward_hook(bwd)

    inp = input_tensor.clone().requires_grad_(True)
    out = model(inp)
    model.zero_grad()
    out[0, target_idx].backward()
    hf.remove()
    hb.remove()

    grad = gradients[0].squeeze()   # (C, H, W)
    act  = activations[0].squeeze() # (C, H, W)
    w    = grad.mean(dim=[1, 2])    # (C,)

    cam = torch.zeros(act.shape[1:])
    for i, wi in enumerate(w):
        cam += wi * act[i]
    cam = F.relu(cam)
    if cam.max() > 0:
        cam = cam / cam.max()
    cam = cv2.resize(cam.numpy(), (224, 224))
    return cam

# ── Util ──────────────────────────────────────────────────────────────────────
def to_b64_png(arr_rgb):
    arr_bgr = cv2.cvtColor(arr_rgb.astype(np.uint8), cv2.COLOR_RGB2BGR)
    _, buf = cv2.imencode(".png", arr_bgr)
    return base64.b64encode(buf).decode()

# ── Endpoint ──────────────────────────────────────────────────────────────────
@app.post("/analyze")
async def analyze(file: UploadFile = File(...)):
    img_bytes = await file.read()
    pil_img   = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    tensor    = TRANSFORM(pil_img).unsqueeze(0)   # (1, 3, 224, 224)

    with torch.no_grad():
        logits = model(tensor)
        probs  = F.softmax(logits, dim=1)[0].tolist()

    pred_idx   = int(np.argmax(probs))
    pred_class = CLASS_NAMES[pred_idx]            # "bleached" | "dead" | "healthy"

    cam         = generate_gradcam(model, tensor, pred_idx)
    heat_bgr    = cv2.applyColorMap(np.uint8(255 * cam), cv2.COLORMAP_JET)
    heat_rgb    = cv2.cvtColor(heat_bgr, cv2.COLOR_BGR2RGB)
    orig_np     = np.array(pil_img.resize((224, 224)), dtype=np.uint8)
    overlay_rgb = cv2.addWeighted(orig_np, 0.55, heat_rgb, 0.45, 0)

    return JSONResponse({
        "predicted_class": pred_class,
        "confidence":      round(probs[pred_idx], 4),
        "probabilities":   {CLASS_NAMES[i]: round(p, 4) for i, p in enumerate(probs)},
        "gradcam_b64":     to_b64_png(overlay_rgb),
        "heatmap_b64":     to_b64_png(heat_rgb),
    })
