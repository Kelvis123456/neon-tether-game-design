# PHASE 5 REPORT: UX/UI Prototyping

This document outlines the design structure of the UX/UI prototype for **Neon Tether** and justifies our technical choice for the prototype platform.

---

## 1. Platform Choice & Justification
Instead of using Figma or Pencil Project for static vector wireframes, we developed a **fully interactive HTML5/CSS3/JS Web Prototype**.

### Why HTML5 over Figma?
1. **Physical Gamefeel Validation:** The core mechanic of Neon Tether (Hold to Split, Release to Snap-Merge) is entirely physics-based. A static Figma layout cannot represent the tactile easing curve or physical response delay.
2. **Audio-Reactive Feasibility:** Using the Web Audio API, we could directly synthesize the sound effects in real-time, allowing testers to hear the chord harmonics sync with their actions.
3. **True Screen Navigation:** All flows (Main Menu -> Shop -> Settings -> Tutorial -> Game Play -> Game Over -> Leaderboard Events) are fully navigable on any browser, testing real button sizes, tap targets, and cognitive load.
4. **Immediate Accessibility:** Zero dependencies. Testers can simply open `index.html` on their mobile phone or PC browser to play.

---

## 2. Navigable Screen Flows
The prototype maps out the complete flow of the production mobile app:

```
[Splash/Inicio] ──> [Main Menu] ──> [Tutorial Mode] ──> Unlocks First Achievement
                          │
         ┌────────────────┼────────────────┬────────────────┐
         ▼                ▼                ▼                ▼
   [Grid Shop]       [Leaderboard]    [Settings]       [Gameplay HUD]
   (Tether Skins,    (Daily Event)    (Haptics,        (Distance score,
    Core Skins, IAPs)                  Volume,         Crystals, Grazing
                                       Colorblind)      combos, Pause)
                                                            │
                                                            ▼
                                                       [Game Over]
                                                       (Rewarded ad, Retry)
```

---

## 3. UX Design Decisions & Solved Issues
During testing of the interactive prototype, we resolved several key UX issues:
* **Haptic Easing:** We matched the mobile haptic feedback to the physics: a soft vibration hum for holding/splitting, and a sharp, sudden pulse for snapping back together.
* **Grazing Multiplier Visiblity:** We placed the combo multiplier HUD at the top center with an animated pulse size, signaling successful risk-taking immediately to the player.
* **One-Handed Layout:** All primary interface buttons (Play, Shop categories, Config switches, Retries) are located in the middle or bottom half of the screen, ensuring easy reach with a single thumb.
* **Dynamic Grid Shader:** A perspective grid moves vertically relative to the descend speed, providing a clean spatial reference of velocity.

---

## 4. Launching the Prototype
To test the prototype:
1. Navigate to the folder `prototype/` in the project root: `C:/Users/Usuario/Documents/AntigravityGame/prototype/`
2. Open [index.html](file:///C:/Users/Usuario/Documents/AntigravityGame/prototype/index.html) in any modern browser.
3. Click or tap to navigate menus, select skins, toggles settings, and play the simulated physics run!
