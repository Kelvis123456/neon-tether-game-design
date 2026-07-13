# RISKS REGISTER: Neon Tether

This document registers potential technical, design, or commercial risks and outlines mitigation strategies.

---

| ID | Description | Impact | Probability | Mitigation Strategy | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **RSK-001** | Game isn't fun or lacks "hook" | High | Medium | Develop vertical slice early; iterate on core mechanics repeatedly before full coding. | Mitigated — browser prototype validated the graze/combo feel; spring easing tuned in Phase 9. |
| **RSK-002** | Platform performance issues (mobile devices) | High | Low | Conduct profiling early; design with low draw-calls and lightweight physics; optimize draw cycles. | Open — no mobile build exists yet; profiling only possible once Phase 10 (Godot port) starts. |
| **RSK-003** | Scope creep (over-complicating systems) | Medium | High | Rely strictly on Phase 4 GDD; ensure every mechanic justifies its footprint. | Open. |
| **RSK-004** | Intrusive/Pay-to-Win monetization driving players away | High | Low | Commit strictly to ethical, cosmetic-only monetization. Retain players with pure gameplay and rewarding events. | Open — prototype simulates IAP with `alert()`, real SDK integration pending Phase 10. |
| **RSK-005** | Godot port (Phase 10) diverges from the feel validated in the JS prototype (different physics step, input latency model) | Medium | Medium | Port the exact spring-easing constants (K=0.18) and collision thresholds documented in `docs/phase_9_vertical_slice.md`; A/B feel-test against the browser prototype before locking Phase 10. | Open — new risk identified during 2026-07-13 review. |
