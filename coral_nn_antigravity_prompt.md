# Coral Neural Networks — Antigravity Flutter App Prompt

## Working Directory

Antigravity operates inside:
```
Desktop/coral neural networks/
```

This folder already contains:
```
coral neural networks/
├── best_model/                              ← PyTorch checkpoint (extracted zip archive)
│   ├── .data/                              ← hidden folder with tensor binary files (DO NOT TOUCH)
│   ├── data/                               ← may also contain tensor data
│   ├── byteorder                           ← "little"
│   ├── data.pkl                            ← model weights pickle
│   └── version                             ← "3"
├── cleaned_upload_screen_no_al/            ← Stitch design assets for Screen 1
├── interactive_analysis_results_dashboard/ ← Stitch design assets for Screen 2
├── oceanic_metric/                         ← design palette/notes from Stitch
└── class_names (1).json                    ← ["bleached", "dead", "healthy"]
```

**Do not move, rename, or modify any existing files or folders.** Create only two new folders:

```
coral neural networks/
├── ... (existing folders untouched) ...
├── coral_app/      ← NEW: Flutter project
└── backend/        ← NEW: Python FastAPI backend
```

---

## Step 0 — Read Design Assets Before Writing Any Code

Before writing a single line of Flutter or Python, open and read:
- `cleaned_upload_screen_no_al/` — all files inside (PNG, JSON, HTML, CSS)
- `interactive_analysis_results_dashboard/` — all files inside
- `oceanic_metric/` — extract exact hex colors, font sizes, spacing values

Use whatever format the files are in. Extract exact values — do not approximate.

---

## Confirmed Model Facts (from inspecting data.pkl)

These are verified — do not guess or change them:

**Architecture:** Standard `torchvision.models.efficientnet_b0` wrapped in `torch.nn.DataParallel`

**State dict key prefix:** All keys are prefixed with `module.` because the model was saved after wrapping with `DataParallel` on Kaggle's GPU. You MUST strip this prefix when loading on CPU.

**Classifier head (confirmed from data.pkl):**
```
module.classifier.0  → Dropout
module.classifier.1  → Linear(in_features=1280, out_features=3, bias=True)
```
This is the standard EfficientNet-B0 head with `num_classes=3`. No custom layers, no extra Linear layers.

**Class names (confirmed from class_names (1).json):**
```python
["bleached", "dead", "healthy"]
# Index 0 = bleached, Index 1 = dead, Index 2 = healthy
```
Note: all lowercase. Format them with `.title()` for display (e.g. "Bleached Coral").

**Grad-CAM target layer:** `model.features[-1]` which is `model.features[8]` — the last Conv2dNormActivation block before the classifier.

**Model loading — exact code (use this verbatim):**
```python
import torch
from torchvision.models import efficientnet_b0
from collections import OrderedDict

# Build model
model = efficientnet_b0(weights=None)
model.classifier[1] = torch.nn.Linear(1280, 3)

# Load checkpoint — best_model/ is an extracted PyTorch zip archive
# Reconstruct the zip from its parts, then load
import zipfile, tempfile, os

def load_model_from_folder(folder_path):
    tmp = tempfile.mkdtemp()
    archive_path = os.path.join(tmp, "best_model.zip")
    with zipfile.ZipFile(archive_path, "w") as zf:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                full_path = os.path.join(root, file)
                arcname = os.path.join("archive", os.path.relpath(full_path, folder_path))
                zf.write(full_path, arcname)
    raw = torch.load(archive_path, map_location="cpu", weights_only=False)
    return raw

raw_state = load_model_from_folder("../best_model")

# Strip "module." prefix from DataParallel keys
new_state = OrderedDict()
for k, v in raw_state.items():
    new_key = k.replace("module.", "", 1)
    new_state[new_key] = v

model.load_state_dict(new_state)
model.eval()
```

---

## Design System — Oceanic Metric Palette

Use these values (verify against `oceanic_metric/` folder — override if exact values differ):

```dart
const Color kPrimaryTeal     = Color(0xFF0D9488);
const Color kDarkTeal        = Color(0xFF0F766E);
const Color kLightTeal       = Color(0xFF99F6E4);
const Color kBackgroundLight = Color(0xFFF0FDFA);
const Color kCardBackground  = Color(0xFFFFFFFF);
const Color kBorderGrey      = Color(0xFFE2E8F0);
const Color kTextPrimary     = Color(0xFF1E293B);
const Color kTextSecondary   = Color(0xFF64748B);
const Color kHealthyGreen    = Color(0xFF22C55E);
const Color kBleachedAmber   = Color(0xFFF59E0B);
const Color kDeadRed         = Color(0xFFEF4444);
const Color kGradientTop     = Color(0xFFCCFBF1);
const Color kGradientBottom  = Color(0xFFE0F2FE);
```

Typography, shapes, and spacing — extract from design files. Defaults:
- App bar title: 16sp, w600, kPrimaryTeal, centered
- Section headings: 16sp, w700, kTextPrimary
- Labels (ALL CAPS): 11sp, w600, letterSpacing 1.5, kTextSecondary
- Body: 14sp, w400, kTextSecondary
- Cards: BorderRadius.circular(16)
- Buttons: BorderRadius.circular(12)
- Background: LinearGradient(kGradientTop → kGradientBottom) on every Scaffold

---

## Flutter Project — `coral_app/`

```bash
cd "Desktop/coral neural networks"
flutter create coral_app
```

### File Structure

```
coral_app/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── theme.dart
    ├── models/
    │   └── analysis_result.dart
    ├── screens/
    │   ├── upload_screen.dart
    │   └── results_screen.dart
    ├── widgets/
    │   ├── upload_zone.dart
    │   ├── probability_bar.dart
    │   └── analysis_image_card.dart
    └── services/
        └── model_service.dart
```

### `pubspec.yaml`

```yaml
name: coral_app
description: Coral health classification using EfficientNet-B0

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  image_picker: ^1.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

---

## Screen 1 — Upload Screen

Matches: `cleaned_upload_screen_no_al/` (read the files in this folder and match exactly)

### Layout (top → bottom, gradient Scaffold)

1. **App Bar** — transparent, elevation 0, centered title `"Coral Neural Networks"` in kPrimaryTeal

2. **Section label** — `"NEW ANALYSIS"` all caps, 11sp, w600, letterSpacing 1.5, kPrimaryTeal, padding top 24 horizontal 24

3. **Heading** — RichText, 26sp w700:
   - `"Upload a photo of coral\nto begin "` in kTextPrimary
   - `"analysis"` in kPrimaryTeal

4. **Upload Zone Card** (`upload_zone.dart`)
   - White card, radius 12, dashed border 1.5px kBorderGrey
   - **Empty state:**
     - Teal circle + `Icons.add_a_photo_outlined` (32, white)
     - `"Drop your image here"` 15sp w600 kTextPrimary
     - `"Select a file from your device."` 13sp kTextSecondary
     - Pill badges: `"JPG / PNG"` and `"UP TO 25 MB"`
   - **Loaded state:**
     - `ClipRRect` image preview, radius 10, fit: cover, height 180
     - Filename in 11sp kTextSecondary below
   - Tap → `ImagePicker(source: ImageSource.gallery)`
   - State: `File? _selectedImage`

5. **Cancel button** (only when image loaded)
   - `Icons.close` + `"Cancel"` — 13sp kTextSecondary
   - Tap → `setState(() => _selectedImage = null)`

6. **Analyse Image button** (full width, bottom, height 52, radius 12)
   - Active (image loaded): kDarkTeal bg, `Icons.bar_chart` white, `"Analyse Image"` white 15sp w600
   - Inactive: kBorderGrey bg, disabled
   - Tap (active only):
     - Show full-screen loading Stack overlay: semi-black + `CircularProgressIndicator(color: kPrimaryTeal)`
     - Call `await ModelService.analyzeImage(_selectedImage!)`
     - Success → `Navigator.push(MaterialPageRoute(builder: (_) => ResultsScreen(result: result, imageFile: _selectedImage!)))`
     - Error → dismiss overlay + `ScaffoldMessenger.showSnackBar("Could not reach analysis server. Is the backend running?")`

---

## Screen 2 — Results Screen

Matches: `interactive_analysis_results_dashboard/` (read the files in this folder and match exactly)

Receives: `AnalysisResult result` + `File imageFile`

### Layout (SingleChildScrollView, gradient Scaffold)

1. **App Bar** — back arrow (kPrimaryTeal) → `Navigator.pop`, same title

2. **Hero Image** — `Image.file(imageFile)`, full width, height 200, fit: cover, flush (no radius)

3. **Primary Diagnosis Card**
   - Background: kPrimaryTeal, bottom radius 16
   - `"PRIMARY DIAGNOSIS"` — 10sp w600 letterSpacing 1.5, white 75% opacity
   - `result.predictedClass.title() + " Coral"` — 28sp w700 white (e.g. `"Bleached Coral"`)
   - `"${(result.confidence * 100).round()}% confidence"` — 14sp white 85% opacity

4. **Probability Spectrum** (padding horizontal 20, top 20)
   - Title: `"Probability Spectrum"` 16sp w700 kTextPrimary
   - Three `ProbabilityBar` widgets in order: **healthy → bleached → dead**
   - Each bar:
     - Label: ALL CAPS class name, 11sp w600 letterSpacing 1.2
     - Color: kHealthyGreen / kBleachedAmber / kDeadRed (matched to class)
     - `TweenAnimationBuilder<double>(duration: Duration(milliseconds: 800))` animating 0→probability
     - Bar track: kBorderGrey height 6 circular
     - Percentage right-aligned: `"${(prob*100).toStringAsFixed(1)}%"` 13sp w600 kTextPrimary

5. **Analysis Results** (padding horizontal 20, top 20)
   - Title: `"Analysis Results"` 16sp w700 kTextPrimary
   - Row of 3 `AnalysisImageCard` widgets (equal flex, gap 8):
     - **ORIGINAL** — `Image.file(imageFile)`
     - **GRAD-CAM** — `Image.memory(result.gradcamImage)`
     - **HEATMAP** — `Image.memory(result.heatmapImage)`
   - Each card: white bg, radius 10, shadow (blurRadius 6, y-offset 2, black 8%), image height 100 fit:cover, label 10sp centered ALL CAPS kTextSecondary below

6. **Footer** (padding bottom 24)
   - `Icons.info_outline` 12sp + `"Highlighted regions show which areas influenced the model's decision."` 11sp italic kTextSecondary

---

## Data Model — `models/analysis_result.dart`

```dart
import 'dart:typed_data';

class AnalysisResult {
  final String predictedClass;             // "bleached" | "dead" | "healthy" (lowercase from model)
  final double confidence;                 // 0.0 – 1.0
  final Map<String, double> probabilities; // {"bleached": 0.87, "dead": 0.03, "healthy": 0.10}
  final Uint8List gradcamImage;            // PNG bytes of grad-cam overlay
  final Uint8List heatmapImage;            // PNG bytes of raw heatmap

  AnalysisResult({
    required this.predictedClass,
    required this.confidence,
    required this.probabilities,
    required this.gradcamImage,
    required this.heatmapImage,
  });
}
```

Display helper — use `predictedClass[0].toUpperCase() + predictedClass.substring(1)` to capitalise.

---

## Model Service — `services/model_service.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class ModelService {
  static const String _baseUrl = 'http://10.0.2.2:8000'; // host machine from Android emulator

  static Future<AnalysisResult> analyzeImage(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/analyze');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Backend error ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return AnalysisResult(
      predictedClass: json['predicted_class'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      probabilities: Map<String, double>.from(
        (json['probabilities'] as Map).map(
          (k, v) => MapEntry(k as String, (v as num).toDouble()),
        ),
      ),
      gradcamImage: base64Decode(json['gradcam_b64'] as String),
      heatmapImage: base64Decode(json['heatmap_b64'] as String),
    );
  }
}
```

---

## Android Configuration

### `android/app/src/main/AndroidManifest.xml`

Add inside `<manifest>` (before `<application>`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
```

Add to the `<application>` opening tag:
```xml
android:networkSecurityConfig="@xml/network_security_config"
```

### Create `android/app/src/main/res/xml/network_security_config.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
    </domain-config>
</network-security-config>
```

---

## Backend — `backend/app.py`

Location: `Desktop/coral neural networks/backend/app.py`

**Key facts the backend must handle:**
- `best_model/` is an extracted PyTorch zip archive — must be reconstructed as a zip before loading
- State dict keys have `module.` prefix from DataParallel — must be stripped
- Class names are `["bleached", "dead", "healthy"]` (all lowercase, index 0/1/2)
- Classifier is `Linear(1280, 3)` — standard EfficientNet-B0 head, no custom layers
- Grad-CAM hooks on `model.features[8]` (= `model.features[-1]`)

```python
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
```

### `backend/requirements.txt`

```
fastapi
uvicorn[standard]
torch
torchvision
pillow
opencv-python
numpy
```

---

## How to Run

### Step 1 — Start the backend
```bash
cd "Desktop/coral neural networks/backend"
pip install -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 8000
```
Wait until you see:
```
Classes: ['bleached', 'dead', 'healthy']
Model loaded successfully.
Uvicorn running on http://0.0.0.0:8000
```

### Step 2 — Open in Android Studio
- Open → `Desktop/coral neural networks/coral_app`
- Wait for Gradle sync
- Run `flutter pub get`

### Step 3 — Run on emulator
- Launch Android Virtual Device (API 29+)
- Click Run ▶ or `flutter run`
- The app POSTs to `10.0.2.2:8000` = your machine's localhost

---

## Navigation Flow

```
App launch
    └── UploadScreen
            ├── Tap upload zone → ImagePicker (gallery)
            ├── Image selected → preview + Analyse button activates
            ├── Cancel → clear image, back to empty state
            └── Analyse tapped
                    ├── Loading overlay shown
                    ├── POST → http://10.0.2.2:8000/analyze (60s timeout)
                    ├── Error → SnackBar + overlay dismissed
                    └── Success → ResultsScreen(result, imageFile)
                                        └── Back → UploadScreen
```

---

## Complete File Checklist

| File | Action |
|---|---|
| `coral_app/pubspec.yaml` | Create |
| `coral_app/lib/main.dart` | Create |
| `coral_app/lib/theme.dart` | Create — all color/text constants |
| `coral_app/lib/models/analysis_result.dart` | Create |
| `coral_app/lib/screens/upload_screen.dart` | Create — Screen 1 |
| `coral_app/lib/screens/results_screen.dart` | Create — Screen 2 |
| `coral_app/lib/widgets/upload_zone.dart` | Create |
| `coral_app/lib/widgets/probability_bar.dart` | Create |
| `coral_app/lib/widgets/analysis_image_card.dart` | Create |
| `coral_app/lib/services/model_service.dart` | Create |
| `coral_app/android/app/src/main/AndroidManifest.xml` | Edit — add permissions + networkSecurityConfig |
| `coral_app/android/app/src/main/res/xml/network_security_config.xml` | Create |
| `backend/app.py` | Create |
| `backend/requirements.txt` | Create |

---

*End of prompt. Antigravity: read the Stitch design folders first, implement all files above matching the designs exactly, then open `coral_app/` in Android Studio for emulator testing.*
