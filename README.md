# 👗 ClosetMatch — SwiftUI + Core ML outfit builder

A privacy-first iOS app that lets you digitize your wardrobe, mix & match tops/bottoms/shoes, and get quick “does this go together?” feedback. Powered by **Core ML**, **Vision**, **AVFoundation**, and **SwiftUI** — with weather-aware suggestions and sustainability insights.

> Tech: CoreML, SwiftUI, AVFoundation, Vision (optionally WeatherKit).
> Arch: MVVM (Clean-architecture flavored).

---

## ✨ Features

* **Capture clothing with the camera**

  * Automatic subject detection on a plain background
  * Background removal for clean cut-outs (Vision + Core Image / Core ML)
  * One-tap category suggestion (e.g., “T-Shirt”, “Jeans”, “Sneakers”) with editable labels

* **Build outfits**

  * Pick **upper body**, **lower body**, **shoes**, and more
  * **Similarity slider** + ✅ **green check** indicator to show if an outfit “matches”
  * Try combinations virtually (drag & reorder layers)

* **Weather-aware**

  * Show local conditions and temperature range
  * Tag items as “weather-appropriate” (e.g., coats for cold, shorts for warm)

* **Sustainability insights**

  * ML-driven “wear frequency” score with emoji signals (🟢 worn often / 🟡 average / 🔴 rarely worn)
  * Nudge to rotate underused pieces

* **On-device & private**

  * All recognition runs locally; your closet stays on your device

---

## 📸 Screens

* **Main screen**

  *Add your screenshot here (e.g., `docs/images/main.png`).*

---

## 🧠 How it works (ML / Vision)

* **Background removal**

  * Vision `VNGeneratePersonSegmentationRequest` or a cloth segmentation model → create alpha matte → composite on transparent background
* **Category suggestion**

  * Core ML image classifier (e.g., MobileNet/efficient custom model) predicts label + confidence → user can correct
* **Outfit matching score**

  * Lightweight model or rule-based engine encoding color harmony + category compatibility → mapped to 0–100
  * UI shows slider value and ✅ when score crosses threshold (configurable)
* **Wear frequency**

  * Track wear events per item; exponential decay for “recency”
  * Map score → emoji:
    `≥0.7 🟢`, `0.4–0.69 🟡`, `<0.4 🔴`

---

## 🏗️ Architecture (MVVM)

* **Layers**

  * `Domain` (entities & use cases: `ClothingItem`, `Outfit`, `WearLog`, `RecommendOutfitUseCase`)
  * `Data` (persistence, model store, weather service)
  * `ML` (classification, segmentation, matching)
  * `UI` (SwiftUI views + view models)
* **Reference**

  * Clean SwiftUI architecture inspiration: [https://nalexn.github.io/clean-architecture-swiftui/](https://nalexn.github.io/clean-architecture-swiftui/)

**Suggested folders**

```
Sources/
  App/
  UI/
    Screens/ (Capture, Closet, OutfitBuilder, Weather, Insights)
    Components/
  Domain/
  Data/
    Persistence/ (CoreData or SwiftData)
    Services/ (Weather, Camera, Photos)
  ML/
    Models/ (mlmodel files)
    Pipelines/
  Resources/
```

---

## 🧾 Data model (example)

```swift
struct ClothingItem: Identifiable, Codable {
    enum Category: String, Codable { case top, bottom, shoes, outerwear, accessory, other }
    let id: UUID
    var name: String
    var category: Category
    var dominantColorHex: String?
    var imagePath: String // cut-out PNG
    var createdAt: Date
    var wearCount: Int
    var lastWornAt: Date?
}

struct Outfit: Identifiable, Codable {
    let id: UUID
    var name: String?
    var items: [UUID] // ClothingItem ids
    var matchScore: Double // 0...1
}
```

---

## ⚙️ Getting started

### Requirements

* Xcode 15+ (Swift 5.9+)
* iOS 17+ (Vision segmentation & WeatherKit APIs work great here)

### Setup

1. **Clone & open** the project in Xcode.
2. **Add ML models**

   * Place your `.mlmodel` files in `Sources/ML/Models/`.
   * Example names: `ClothingClassifier.mlmodel`, `BackgroundMatte.mlmodel` (optional if using Vision person segmentation).
3. **Weather provider (optional)**

   * Recommended: **WeatherKit**. Add capability and configure your Team ID & API in Signing.
   * Or wire any provider in `WeatherService`.
4. **Permissions**
   Add to `Info.plist`:

   * `NSCameraUsageDescription` = “We use the camera to capture clothing items.”
   * `NSPhotoLibraryAddUsageDescription` (if saving)
   * `NSPhotoLibraryUsageDescription` (if importing)

### Run

* Select a device (camera features require a real device) and **Run**.

---

## 🔐 Privacy

* All classification and matching **run on-device**.
* Images remain local unless you export or share them.

---

## 🧪 Key components

* `CameraService` — AVFoundation capture, still photo output, background detection hint
* `SegmentationPipeline` — Vision/Core Image matting → PNG with alpha
* `Classifier` — Core ML model wrapper with label map + human-readable names
* `MatchingEngine` — color harmony + category rules (+ optional Core ML regressor)
* `WeatherService` — WeatherKit (or adapter)
* `WearTracker` — logs wears, computes frequency score

---

## 🗺️ Roadmap

* Virtual try-on scale/pose assist (Vision human body landmarks)
* Color picker / auto dominant color extraction
* Bulk import from Photos (background removal batch)
* iCloud sync (CloudKit)
* Widgets: Today’s outfit & “wear me” suggestion
* Accessibility: VoiceOver labels for match explanations

---

## 🙌 Inspiration & references

* WWDC 2025 winners & examples: [https://github.com/wwdc/2025](https://github.com/wwdc/2025)
* EcoVision: [https://github.com/HtetAungShine6/EcoVision](https://github.com/HtetAungShine6/EcoVision)
* Clean architecture for SwiftUI: [https://nalexn.github.io/clean-architecture-swiftui/](https://nalexn.github.io/clean-architecture-swiftui/)
* Articles & camera tips:
  [https://www.createwithswift.com/](https://www.createwithswift.com/)
  [https://www.artemnovichkov.com/blog](https://www.artemnovichkov.com/blog)
  [https://medium.com/@mijick/how-to-implement-camera-in-a-swift-way-30485d9fbb8d](https://medium.com/@mijick/how-to-implement-camera-in-a-swift-way-30485d9fbb8d)

> Note: You mentioned “MLKit” — this is Google’s library. On iOS, you can stay fully Apple-native with **Core ML + Vision**. If you still prefer ML Kit, adapt the `Classifier`/`SegmentationPipeline` behind protocol-based facades.

---

## 🧩 FAQ

**Why a slider and a green check?**
The slider shows the numeric match score; the ✅ appears after the score crosses a threshold (e.g., 0.72). Users get both nuance and a simple verdict.

**What if the model mislabels an item?**
Users can quickly correct the label; we store that as truth and (optionally) log it to improve future on-device models.

---

## 📄 License

MIT — see `LICENSE` (add one if missing).

---

## 📨 Contributing

PRs welcome! Please:

1. Open an issue describing the change.
2. Follow the folder structure above.
3. Include screenshots for UI tweaks & sample items for ML-related changes.

---

## 🧰 Quick tips (dev)

* Use **`VNDetectHumanRectangles`** / person segmentation to prime the crop.
* Export cut-outs as **PNG** with alpha for crisp layering.
* Cache thumbnails aggressively (closet grid).
* Keep ML labels minimal and user-friendly (Top, Bottom, Shoes, Outerwear, Accessory).

