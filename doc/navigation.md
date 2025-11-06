# 🗺️ Navigation Architecture

```text
[Splash Screen]
   │
   ├── No profiles → [Profile Creation]
   │                     │
   │                     └── [Exercise Type Selection]
   │
   ├── Multiple profiles → [Profile Selector]
   │                     │
   │                     ├── Select profile → [Exercise Type Selection]
   │                     └── New profile → [Profile Creation]
   │
   └── One profile → [Exercise Type Selection]
                         │
                         ├── Additions → [Mode Selection]
                         │                   ├── Revision → [Revision Mode]
                         │                   └── Exercise → [Exercise Type Selection]
                         │                                           ├── Multiple Choice → [Exercise A]
                         │                                           │                          └── [Results]
                         │                                           └── Direct Input → [Exercise B]
                         │                                                                         └── [Results]
                         │
                         └── Multiplications → (same structure)
                                                    │
                                                    └── [Results]
                                                         │
                                                         └── [Statistics Screen]
```

### 🔁 Reverse Navigation
- Every screen includes a “Home” or “Back” button.
- From Results → options:
  - Replay
  - View Statistics
  - Return Home
