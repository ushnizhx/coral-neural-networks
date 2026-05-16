# Coral Neural Networks - Comprehensive Project Documentation

## 1. Product Requirements Document (PRD)

**Product Name:** Coral Neural Networks
**Target Audience:** Marine Biologists, Conservationists, Environmental Researchers, SCUBA Divers.
**Objective:** Provide a standalone mobile application capable of diagnosing coral health (Healthy, Bleached, At Risk / Dead) from images using an AI model, and providing visual explanations via Grad-CAM heatmaps.

### Key Features:
- **Image Upload:** Users can intuitively upload images from their device gallery.
- **AI Inference:** The app processes the image and returns a primary diagnosis with confidence levels.
- **Explainability:** Displays Grad-CAM heatmaps to show exactly which parts of the coral contributed to the diagnosis, ensuring trust in the AI's decision.
- **Standalone Capability:** Works wirelessly via an Ngrok tunnel to a FastAPI backend (or local USB tether).
- **Responsive UI:** A clean, professional, and accessible user interface tailored for field researchers.

---

## 2. Technical Requirements Document (TRD)

**Frontend Architecture:**
- **Framework:** Flutter (Dart 3.x)
- **Target Platforms:** Android (APK)

**Backend Architecture:**
- **Framework:** FastAPI (Python 3.12)
- **Server:** Uvicorn (ASGI)
- **Tunneling:** Ngrok for remote wireless access.

**AI/ML Pipeline:**
- **Model Architecture:** EfficientNet-B0 (PyTorch)
- **Input:** 224x224 RGB Images
- **Outputs:** Probabilities for 3 classes (Healthy, Bleached, Dead).
- **Explainability:** Grad-CAM (Gradient-weighted Class Activation Mapping) on the final convolutional layer (`model.features[8]`).

**Dependencies:**
- **Python:** `torch`, `torchvision`, `fastapi`, `uvicorn`, `opencv-python`, `pillow`, `python-multipart`
- **Flutter:** `http`, `image_picker`, `flutter_launcher_icons`

---

## 3. App Flow

1. **Launch Screen:** Displays the "Coral Neural Networks" branding.
2. **Home/Upload Screen:**
   - Displays a custom underwater coral background.
   - User taps the image picker area to select a photo from the gallery.
   - Once selected, the image is previewed, and the "Analyze Image" button is enabled.
3. **Processing State:**
   - User taps "Analyze Image".
   - A full-screen loading overlay appears while the image is securely sent to the backend.
4. **Results Dashboard:**
   - **Primary Diagnosis:** Displays the top class and confidence score in a prominent gradient card.
   - **Probability Spectrum:** Shows animated bar charts for all three classes.
   - **Analysis Results:** Shows Original Image, Grad-CAM, and Heatmap side-by-side.
   - **AI Inference Box:** Displays a dynamic, human-readable explanation of the model's findings based on the predicted class.
   - **Navigation:** Back button to return to the upload screen for the next analysis.

---

## 4. UI/UX Design Brief

**Design System:** "Aquatic Lens"
**Core Philosophy:** Clean, scientific, trustworthy, and minimal.

**Color Palette:**
- **Primary Teal:** `#007B83`
- **Background Light:** `#F6FAFE`
- **Card Surface:** `#EBF4F9`
- **Healthy (Green):** `#38B2AC`
- **Bleached (Amber):** `#F6AD55`
- **Dead (Red):** `#F56565`
- **Text Primary:** Dark Slate Gray (`#1A1C1E`)
- **Text Muted:** `#4A5568`

**Typography:**
- **Headlines:** Manrope (Clean, structural sans-serif)
- **Body:** Inter (Highly readable sans-serif)
- **Styles:** Bold for primary data (diagnosis), regular for explanatory text.

**Components:**
- **Buttons:** Pill-shaped (`9999dp` radius), filled with Primary Teal.
- **Cards:** Rounded rectangles (`12dp` or `16dp` radius), soft shadows (`blurRadius: 24`, `offset: 0, 8`).
- **Inference Box:** Left-accented card with a teal vertical bar and dark circular AI icon.

---

## 5. Backend Schema (API Contract)

**Endpoint:** `POST /analyze`
**Content-Type:** `multipart/form-data`

**Payload:**
- `file`: The image file (JPEG/PNG) to be analyzed.

**Response (JSON):**
```json
{
  "predicted_class": "string (healthy | bleached | dead)",
  "confidence": "float (0.0 - 1.0)",
  "probabilities": {
    "healthy": "float (0.0 - 1.0)",
    "bleached": "float (0.0 - 1.0)",
    "dead": "float (0.0 - 1.0)"
  },
  "gradcam_b64": "base64_string",
  "heatmap_b64": "base64_string"
}
```

---

## 6. Implementation Plan (Execution Status)

- [x] **Phase 1: AI Model & Backend Setup**
  - [x] Train and export EfficientNet-B0 model.
  - [x] Implement FastAPI server to serve predictions and Grad-CAM images.
- [x] **Phase 2: Mobile App Foundation**
  - [x] Initialize Flutter project.
  - [x] Setup UI theme and basic routing.
- [x] **Phase 3: Core Features**
  - [x] Implement image picking functionality.
  - [x] Integrate HTTP client to communicate with the FastAPI backend.
  - [x] Parse API responses and display results.
- [x] **Phase 4: UI/UX Polish**
  - [x] Apply "Aquatic Lens" design system.
  - [x] Add custom backgrounds and layout refinements.
  - [x] Implement custom AI Inference Box component.
- [x] **Phase 5: Deployment & Connectivity**
  - [x] Integrate Ngrok for wireless demo capability.
  - [x] Setup App Icon and App Name.
  - [x] Build Release APK (`Coral_Neural_Networks.apk`).
