# PHASE 8 REPORT: Technical Architecture Design

This document details the modular software architecture for **Neon Tether**, ensuring separation of concerns, high scalability, and robust performance.

---

## 1. Architectural System Layout

We utilize a decoupled **Model-View-Presenter (MVP)** structure modified for game loops. This ensures that game logic (physics, scoring) is independent of rendering details and audio synthesis.

```
       +---------------------------------------------+
       |                  GameLoop                   |
       +---------------------+-----------------------+
                             | updates 60hz
                             v
       +---------------------------------------------+
       |               GamePlayCore                  |
       |  (Score, Combo, Speed, TetherState, Spawner) |
       +-------+-----------------------------+-------+
               |                             |
               | fires events                | updates positions
               v                             v
+--------------+-------------+        +------+---------------+
|        AudioSynthesizer    |        |      Renderer2D      |
|  (Sweeps, Chord, Chimes)   |        |  (Trails, Shaders)   |
+----------------------------+        +------+---------------+
                                             |
                                             v
                                      +------+---------------+
                                      |   HapticController   |
                                      +----------------------+
```

---

## 2. Modular Component Definition

### 2.1 State Manager (`AppStateMachine`)
Manages the macro application states.
* **States:** `SPLASH`, `MENU`, `PLAYING`, `PAUSED`, `GAMEOVER`.
* **Transitions:** Disposes of gameplay nodes when returning to menu; loads skins in memory.

### 2.2 Gameplay Engine (`GamePlayCore`)
Calculates the physical changes and checks rules:
* **PhysicsController:** Calculates current tether width using a Spring Easing formula:
  $$x_{\text{new}} = x_{\text{current}} + (x_{\text{target}} - x_{\text{current}}) \times K_{\text{spring}}$$
* **ObstacleSpawner:** Manages procedural spawning. Keeps active elements in an Object Pool to prevent garbage collection hiccups.
* **CollisionDetector:** Triggers fail state upon geometric overlap.

### 2.3 Visual View Module (`Renderer2D`)
Responsible for optical output:
* **TrailRenderer:** Manages line buffers for energy trails.
* **TunnelShader:** Controls canvas warping based on current speed.
* **UIUpdater:** Updates score, multiplier, and crystal labels.

### 2.4 Audio & Haptic System
* **AudioSynthesizer:** Dynamically synthesizes chimes, sweeps, and crash impacts.
* **HapticController:** Encapsulates vibration commands.

### 2.5 Local Store System (`SaveSystem`)
* **Functions:** Encrypts and saves stats (High score, Crystal balance, Unlocked skins) to a local JSON file.
* **Key Encryption:** Simple AES-256 wrapping to protect database integrity.

---

## 3. Data Flow Example: Snapping Back
1. Player releases screen touch -> `Input` captures event.
2. `PhysicsController` sets `targetWidth = 10`.
3. `GamePlayCore` ticks, computing spring velocity.
4. `AudioSynthesizer` receives event `ON_MERGE` and synthesizes the C-minor chord envelope.
5. `HapticController` triggers a sharp haptic vibration (80ms).
6. `CollisionDetector` evaluates new bounding box layout.
