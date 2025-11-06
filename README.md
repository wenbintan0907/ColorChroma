# ColorChroma

**ColorChroma** is an iOS application designed to assist users — particularly those with color vision deficiencies — in identifying, understanding, and interacting with colors in their environment.

The app leverages **real-time computer vision** and **Google’s Gemini AI** to provide a suite of tools for color analysis and practical assistance.

> ⚠️ **Note:** This project is currently under development and is **not intended for public use**.

## Images
<img src="images/picture1.png">
<img src="images/picture2.png">
<img src="images/picture3.png">
<img src="images/picture4.png">

## Key Features

### 1. Real-Time Color Identification

* **Instant Analysis:** Point your camera at any object to get its descriptive color name (e.g., *“Vivid Blue”*, *“Dark Dull Green”*) and hex code instantly.
* **Precise Aiming:** A central reticle on the camera screen ensures accurate targeting.
* **AI Descriptions:** Tap the color info panel for an AI-generated description that compares the color to familiar objects and evokes associated feelings.

### 2. AI-Powered Assistants

* **👕 Clothing Matcher:** Upload photos of two clothing items. The AI stylist provides a verdict (e.g., “✅ Excellent Match”) with reasoning based on color theory and contrast.
* **🎨 Color Comparison:** Compare the prominent colors of any two objects and get a detailed explanation of their similarities and differences.
* **📷 Reference Comparison:** Match a live object’s color against a reference image (great for tasks like paint matching or food doneness checks).
* **🧺 Sorting Assistant:** Automatically groups items into broad color categories (e.g., *“Reds & Pinks”*, *“Blues & Purples”*) — ideal for sorting laundry.
* **📊 Chart & Map Analyzer:** Upload an image of a chart, graph, or map. The AI interprets it, describing data, trends, and legends in an accessible format.
* **🥑 Food & Cooking Aid:** Get visual-based AI assistance for checking the ripeness of produce or the doneness of cooked foods.
* **💡 Indicator Scanner:** Identifies the color and probable meaning of status lights on electronic devices.

### 3. Interactive & Learning Tools

* **💬 Chroma AI Chat:** Converse with *Chroma*, a color-specialized AI assistant. Ask about color differences, matches, or theory.
* **📸 Item Labeling & Saving:** Capture and label items, saving their colors to a personal library with **SwiftData**.
* **🧩 Color Perception Test:** An interactive, Ishihara-style color vision test *(for exploration, not diagnosis).*
* **📚 Color Reference:** A searchable library of standard color swatches and hex codes.
* **ℹ️ Information Hub:** Learn about various types of color vision deficiencies and accessibility topics.

## Core Technologies

| Component            | Technology                                          |
| -------------------- | --------------------------------------------------- |
| **Language**         | Swift                                               |
| **UI Framework**     | SwiftUI                                             |
| **AI Model**         | Google Gemini 2.5 Flash Lite                        |
| **Camera**           | AVFoundation (real-time frame capture & processing) |
| **Data Persistence** | SwiftData                                           |
| **Computer Vision**  | Apple’s Vision framework                            |

## Project Structure

```
ColorChroma/
├── ColorChromaApp.swift          # App entry point & onboarding flow
├── MainTabView.swift             # Primary navigation ("Home" & "Tools")
├── HomeScreen.swift              # Dashboard with daily color tip & saved items
├── TasksView.swift               # Categorized list of all available tools
│
├── Features/                     # Individual feature modules
│   ├── LiveScan/
│   │   ├── LiveScanView.swift
│   │   └── LiveScanService.swift
│   ├── Chat/
│   │   ├── ChatView.swift
│   │   └── ChatService.swift
│   └── ClothingMatcher/
│       ├── ClothingMatcherView.swift
│       └── ClothingMatcherService.swift
│
├── DataModels/                   # Shared data structures
│   ├── LabeledItem.swift
│   └── StandardColor.swift
│
└── Resources/                    # Helpers, extensions, and Gemini config
    └── GenerativeAI-Info.plist
```

---

## Configuration

To build and run **ColorChroma**, you’ll need your own **Google Gemini API key**:

1. Navigate to:

   ```
   ColorChroma/Resources/
   ```
2. Open the file:

   ```
   GenerativeAI-Info.plist
   ```
3. Insert your key as the string value for:

   ```
   GEMINI_API_KEY
   ```

> ⚠️ The app will **crash on launch** if a valid API key is not provided.
