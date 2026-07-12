# PHASE 7 REPORT: Engine & Technology Selection

This report evaluates engine alternatives for **Neon Tether** and justifies our technical stack selection to ensure high performance, low input latency, and lightweight builds.

---

## 1. Engine Comparison Matrix

We evaluated six platform engines against our core requirements: stable 60 FPS on low-end mobile devices, low input latency, rich custom shader support, and minimal app bundle size.

| Engine / Stack | Build Size | Input Latency | 2D Shaders / Glows | Portability | Licensing / Cost |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Unity** | ~25 MB | Very Low | Excellent (URP) | High | Royalty limits / Terms |
| **Unreal Engine** | ~100 MB+ | Low | Overkill 3D | Medium-High | 5% Royalty after $1M |
| **Godot (Recommended)** | **~12 MB** | **Extremely Low** | **Excellent (Native 2D)** | **High (iOS/Android)** | **MIT License (Free)** |
| **Defold** | ~4 MB | Extremely Low | Good (Lua) | High | Free / Custom |
| **Flutter + Flame** | ~15 MB | Low-Medium | Medium (Canvas) | High | BSD (Free) |
| **Phaser + Capacitor** | ~8 MB | Medium (Webview) | Good (WebGL) | High | MIT (Free) |

---

## 2. Technical Evaluation

### 2.1 Why Not Unreal or Unity?
* **Unreal Engine:** Irrelevant for a portrait 2D vector timing game. It drains mobile batteries rapidly and swells initial download sizes.
* **Unity:** Although technically viable, the licensing terms are complex, and the runtime engine is heavier than required.

### 2.2 Why Not Hybrid (Capacitor/Phaser)?
* **Input Latency:** Hybrid webviews introduce micro-delays (16-30ms) between a touch event and the logical tick. In a game like *Neon Tether* where precision is measured in frames, any input lag ruins the "graze" combo feel and frustrates players.

### 2.3 The Winner: **Godot Engine (v4.x)**
Godot was selected as the optimal technical foundation for this project:

1. **Native Input Handling:** Direct integration with Android NDK and Apple iOS Touch Events provides sub-millisecond input capture.
2. **Dedicated 2D Canvas & Vector Shaders:** Godot’s custom shading language (GLSL-like) makes rendering neon glows, trails, and grid-scaling simple and cheap, bypassing heavy PNG textures to reduce VRAM pressure.
3. **Extremely Low Footprint:** A fully compiled production build is only ~12MB, easily matching the requirements for Google Play / App Store instant downloads.
4. **GDScript / C# Options:** GDScript is optimized for rapid gameplay iteration and runs comfortably inside a modular architecture.
5. **MIT License:** Completely free of royalties, ensuring the financial sustainability of the project.
