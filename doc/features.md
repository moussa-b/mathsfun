# 📱 Application Features: Multiplication & Addition Revision

## 🎯 Goal
A mobile application designed to help primary school students revise and practice addition and multiplication tables in a fun, cartoon-style environment.

---

## 👤 Profile Management

### 1. Profile Creation
- At first launch, the parent must create a profile for their child.
- Information required:
  - **Nickname**
  - **Class** (CP, CE1, CE2, CM1, CM2)
  - **Avatar** (chosen from a gallery of cartoon-style avatars)
- Profile is stored locally.

### 2. Profile Selector
- If multiple profiles exist:
  - Display a **profile selection screen** with avatars and nicknames.
  - Options available:
    - Select existing profile
    - Create new profile
    - Delete a profile (optional, with confirmation)
- If only one profile exists, skip selection and go directly to the next screen.

### 3. Quick Access
- If there is only one profile, skip directly to the exercise type selection.
- A “Change profile” button remains available in the main menu.

---

## 🧮 Content Selection

### 4. Choose Exercise Type
- After selecting a profile, the child chooses what to study:
  - 🔵 **Multiplication**
  - 🔴 **Addition**

---

## 🧠 Study Modes

### 5. Mode Selection
- Two main study modes:
  1. **Revision Mode** – Display tables with animations and visible answers.
  2. **Exercise Mode** – Active practice mode with user interaction.

### 6. Exercise Types
In Exercise Mode, two formats are available:
- **A. Multiple Choice**
  - Example: 6 × 7 = ? → options: 36, 42, 49, 56
- **B. Direct Input**
  - Example: 9 + 8 = ? → child types the answer.
- **C. Voice** (`ExerciseFormat.voice`, spec `doc/specs/A-mode-oral.md`)
  - The app reads the operation aloud ("6 fois 7"), listens to the spoken answer, says "Bravo !" or "Non, c'était 42", then moves on.
  - Not understood → the app asks the child to repeat, without limit; silence just keeps listening.
  - "Listen again" re-reads the operation; "Skip" moves on (counted wrong). The written feedback is shown too.
  - The microphone stops when the app leaves the foreground or is interrupted; the question is asked again on return.
  - Only the whole session is timed (no per-question timer, whatever the difficulty); each answer time is still stored and shown on the results screen.
  - 100 % on-device: speech recognition with `sherpa_onnx`, text-to-speech from the OS. The model of the app language (Kroko streaming zipformer, ≈ 71 MB in French and in English) is downloaded once from `models.bdzapps.com/asr/manifest-v1.json` (Cloudflare R2), verified by size and sha256 and stored in the OS cache; the tile stays locked until it is ready.
  - Parents can see the model size and delete it in the parent settings, which also show the model credits (CC-BY-SA).
  - Models are prepared with `tool/build_asr_models.sh`.

---

## 📊 Performance Tracking

### 7. Statistics per Profile
- Completion time for exercises
- Number of mistakes
- Success rate (%)
- Historical progress per session

---

## 🎨 Design & User Experience

### 8. Cartoon Theme
- Colorful and engaging cartoon visuals
- Large buttons and readable fonts
- Positive sound feedback
- Blue theme for multiplication / Red for addition

---

## 💡 Optional Enhancements
- Timed challenge mode
- Reward system (stars, badges)
- Parental lock for settings
- Online backup of profiles and stats
