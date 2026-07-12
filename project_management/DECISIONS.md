# DECISIONS LOG: Antigravity Game Project

This document records the design and technical decisions made during the project, detailing the context, options considered, and rationales.

---

## [DEC-001] Project Path Selection

* **Date:** 2026-07-01
* **Status:** Approved
* **Context:** The workspace root is `C:/Windows/System32`, which is a protected system directory. We need a safe user-space directory for development.
* **Options Considered:**
  1. `C:/Windows/System32` (Too risky, permissions issues, potential OS instability).
  2. `C:/Users/Usuario/Documents/AntigravityGame` (Safe, standard documents folder, clean git-ready location).
  3. `C:/Users/Usuario/Desktop/AntigravityGame` (Visible, but clutters user's desktop).
* **Decision:** Option 2 (`C:/Users/Usuario/Documents/AntigravityGame`).
* **Rationale:** It separates our work from system files, avoids visual clutter on the desktop, and is fully accessible.
* **Consequences:** We requested and received write permissions for this folder.
