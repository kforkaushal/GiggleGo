# Giggle Go! — PRD (Agent Build Spec v2)
**For:** Antigravity agent execution
**Platform:** Android, Flutter
**Author note:** This is a corrected version of the original PRD. Items that were missing, unrealistic for a solo beginner, or unsafe for a child-directed app have been fixed. Where something changed, a `⚠ FIX:` note explains why.

---

## 0. How to Use This Document

Give this whole file to the Antigravity agent as the task spec. Do **not** ask it to build everything in one shot — work phase by phase (Section 9), and require the agent to stop and show you a working build at the end of each phase before continuing.

Recommended companion files for the agent session (create empty, let the agent fill them in as it works):
- `PROJECT_STATE.md` — current phase, what's done, what's next
- `AGENT.md` — the guardrails from Section 10, so the agent re-reads its own rules every session
- `TASK_LOG.md` — one line per completed task, so context isn't lost between sessions

---

## 1. Product Vision (unchanged)

Giggle Go! is a colorful, joyful preschool learning app (ages 2–6) where children learn basic concepts through tiny tap-to-match games. It should feel like "Let's play!", never like a lesson.

Loop: **Fun → Discovery → Success → Positive feedback → Repeat**

---

## 2. What V1 Actually Is (Scope Lock)

⚠ **FIX:** The original PRD never explicitly says what is *excluded*. For a solo beginner, an unbounded scope is the #1 reason projects stall. Lock it down:

**V1 IS:**
- 5 mini-games: Colors, Fruits, Animals, Vehicles, Shapes
- Emoji-based visuals (see Section 3 — this removes the need for custom illustration)
- Local-only data, no login, no internet required
- Stars as the only reward currency
- One difficulty behavior: 3 choices per question (Normal), no difficulty selector in V1

**V1 IS NOT (do not let the agent add these even if it seems easy):**
- No custom illustrated art / mascot artwork
- No difficulty selector UI (Easy/Normal/Challenge) — pick Normal only, add the selector in V1.1
- No numbers, ABC, memory, puzzles, coloring
- No ads, no in-app purchases, no "Unlock All" logic
- No Firebase, no accounts, no cloud sync
- No voice narration (TTS) — text + emoji only
- No custom fonts requiring licensing research — system default font only

Anything not on the "IS" list is out of scope for V1, full stop.

---

## 3. Asset Strategy — Emoji First

⚠ **FIX:** The original PRD assumes a full illustration pipeline (custom fruit/animal/vehicle/shape art in a "consistent style"). That requires either hiring an illustrator or weeks of asset production — not realistic for a solo beginner building alone. The original mockups already show emoji (🔴🍎🐶🚗○) — so V1 formalizes that as the actual asset strategy, not just a placeholder.

- All game items render as large `Text` widgets using emoji characters (e.g. `🍎`, `🐶`, `🚗`, `🔴`, `○`)
- No image assets are required for gameplay in V1
- This also solves offline size, consistency-of-style, and cross-device rendering (emoji are OS-provided)
- Mascot, custom illustrations, and app icon artwork are explicitly deferred to V1.1 (Section 12). For V1, the app icon can be a simple colored circle with a star or a single large friendly emoji — a placeholder, not a final brand asset.

---

## 4. Technical Stack (exact, no ambiguity)

- Flutter SDK: latest stable channel at build time (agent should run `flutter --version` and record it in `PROJECT_STATE.md`)
- Dart: bundled with Flutter SDK
- minSdkVersion: 21 (covers effectively all active Android devices; do not go lower — no benefit, adds compatibility risk)
- targetSdkVersion: latest required by current Google Play policy at submission time
- Package/App ID: `com.<yourname>.gigglego` (agent must ask you for `<yourname>` before running `flutter create` — do not let it invent one)
- State management: **plain `StatefulWidget` + `setState` only**. ⚠ FIX: no Riverpod/Bloc/Provider for V1 — this app has one score counter and one current-question index per game; a state management library is unnecessary complexity for a beginner project of this size.
- Persistence: `shared_preferences` (see Section 6) — ⚠ FIX: original PRD had no persistence layer at all, meaning stars/progress would reset every time the app closes. This is a functional gap, not a nice-to-have.
- Audio: `audioplayers: ^6.0.0` (as specified originally)
- No other packages unless a later phase explicitly calls for one.

### pubspec.yaml dependencies block (exact)
```yaml
dependencies:
  flutter:
    sdk: flutter
  audioplayers: ^6.0.0
  shared_preferences: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

---

## 5. Folder Structure (exact)

```
lib/
├── main.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── game_screen.dart
│   ├── result_screen.dart
│   └── parent_area_screen.dart
├── models/
│   └── game_item.dart
├── data/
│   ├── colors_data.dart
│   ├── fruits_data.dart
│   ├── animals_data.dart
│   ├── vehicles_data.dart
│   └── shapes_data.dart
├── services/
│   └── storage_service.dart      // wraps shared_preferences
└── widgets/
    ├── game_card.dart
    ├── answer_card.dart
    └── star_counter.dart
```

No `assets/images/` folder is needed for V1 (see Section 3). Keep `assets/sounds/` only:
```
assets/
└── sounds/
    ├── correct.mp3
    ├── wrong.mp3
    └── complete.mp3
```
⚠ Sound files must be sourced from a royalty-free library (e.g. Pixabay Audio, Freesound with a compatible license) before the agent references them — the agent should never fabricate audio files, and should pause and ask you to supply the 3 mp3 files if they aren't present yet.

---

## 6. Data Model & Persistence

```dart
class GameItem {
  final String emoji;
  final String name;
  final String category;

  GameItem({
    required this.emoji,
    required this.name,
    required this.category,
  });
}
```

Example (`fruits_data.dart`):
```dart
final List<GameItem> fruitsData = [
  GameItem(emoji: "🍎", name: "Apple", category: "fruit"),
  GameItem(emoji: "🍌", name: "Banana", category: "fruit"),
  GameItem(emoji: "🍊", name: "Orange", category: "fruit"),
  // 10–15 total items is enough for V1
];
```

### Persistence (⚠ FIX — missing in original)
`storage_service.dart` wraps `shared_preferences` and stores:
- `stars_<category>` (int) — total stars earned per category, persists across app restarts
- `sound_enabled` (bool) — from the settings toggle

No other persisted state is needed for V1. No user accounts, no cloud sync.

---

## 7. Game Logic (explicit, so the agent can't improvise incorrectly)

1. Each game session pulls a shuffled copy of that category's data list.
2. Take the first 10 items as the session's questions (if fewer than 10 exist, use `min(10, list.length)` and don't crash).
3. For each question:
   - The "target" item is the current item.
   - Pick 2 other *different* items at random from the same category to serve as wrong choices (3 total choices — Normal difficulty only, per Section 2).
   - Shuffle the 3 choices so the correct answer is **never in a fixed position** — use `list.shuffle()` on the choices array each question, don't hardcode position logic.
4. On tap:
   - Correct → play `correct.mp3` (if sound on) → show "Yay!" / "Great!" / "Awesome!" (rotate between a small fixed set of these strings, don't repeat the same one twice in a row) → +1 star for this session → advance after a short delay (~800ms) or on next tap, agent's choice, but must be consistent.
   - Incorrect → play `wrong.mp3` (if sound on) → show "Try again!" with a gentle shake animation → **do not advance** — let the child try the same question again. ⚠ FIX: original PRD didn't specify whether a wrong answer blocks progress or skips forward; blocking and re-trying is the correct choice for this age group (no unresolved failure state).
5. After 10 questions: go to Result Screen, show stars earned this session (out of 10 max), add session stars to the persisted category total from Section 6.

---

## 8. Screens & Navigation (unchanged from original, confirmed correct)

```
Splash → Home → Choose Game → Question → Answer → Reward → Next Question
       → Complete → Play Again / Home
```

Parent Area is reached only through a **parental gate** (⚠ FIX — original PRD mentioned a parental gate should exist "appropriately" but never specified what it is). For V1:
- Home screen has a small, low-emphasis settings icon (not styled to attract a child's attention)
- Tapping it shows a simple math check appropriate for an adult, e.g. "What is 7 + 5?" with a plain number keypad — not a game, no bright colors, no emoji
- Only on a correct answer does it open Parent Area (Sound toggle, About, Privacy Policy link, Rate App)

---

## 9. Realistic Build Plan (replaces the "7-Day Target")

⚠ **FIX:** The original 7-day plan (including two full mini-games in a single day, twice) is not realistic for someone building this as their first solo app alongside other commitments. Below is the same scope, broken into agent-sized phases instead of calendar days. Each phase ends with a **Definition of Ready** the agent must confirm before moving to the next phase — this is your checkpoint to actually look at the running app.

### Phase 1 — Foundation
Build: Flutter project scaffold, folder structure (Section 5), theme (colors/typography only, no assets needed), Splash screen, Home screen with 5 static game cards (non-functional taps OK).
**Definition of Ready:** `flutter run` launches on a device/emulator, Home screen shows all 5 cards, no crashes.

### Phase 2 — Core Game Engine
Build: `GameItem` model, one working category (Colors) end-to-end: question generation, shuffled choices, correct/wrong logic, star counting, advancing through 10 questions.
**Definition of Ready:** Colors game is fully playable start to finish, including a wrong-answer case and a full 10/10 session.

### Phase 3 — Remaining Categories
Build: Fruits, Animals, Vehicles, Shapes data files, wired into the same game engine from Phase 2 (no new logic, just new data).
**Definition of Ready:** all 5 categories playable, each pulling from its own data file.

### Phase 4 — Persistence, Sound, Polish
Build: `storage_service.dart`, star totals persisting across app restart, sound integration (with the 3 mp3 files supplied by you), simple win/wrong animations using `AnimatedScale`/`AnimatedOpacity` (no external animation package).
**Definition of Ready:** close and reopen the app — star totals are still there; sound toggle in Parent Area actually mutes/unmutes.

### Phase 5 — Result Screen & Parent Area
Build: Result screen (stars earned, Play Again / Home), Parent Area with parental gate (Section 8), About + Privacy Policy link (placeholder link is fine until Section 11 is done).
**Definition of Ready:** full loop Home → Game → Result → Home works with no dead ends.

### Phase 6 — Device Testing & Bug Fixing
Test on: at least one budget/low-end Android device or emulator profile, at least one larger screen, portrait-only lock confirmed, offline (airplane mode) confirmed fully playable.
**Definition of Ready:** no crashes across the above, matches the Definition of Done checklist (Section 13).

There is no fixed calendar length — move to the next phase only when the current one's Definition of Ready is actually true, not when it "should" be done.

---

## 10. Guardrails for the Antigravity Agent

⚠ **FIX:** the original PRD gives the agent no operating rules — it's a spec of *what* to build, not *how to behave* while building it. Add explicitly:

1. **One phase at a time.** Do not start Phase N+1 until you've told me Phase N's Definition of Ready is met and I've confirmed it.
2. **Ask, don't assume, for:** the app ID suffix (Section 4), the 3 sound files (Section 5), and anything in Section 2's "IS NOT" list if it seems tempting to add "while you're in there."
3. **Commit to git after every phase**, with a message naming the phase (e.g. `Phase 2: core game engine complete`). Never squash or rewrite history without asking.
4. **Never introduce a new package** not listed in Section 4 without stopping to ask first.
5. **Never touch a previous phase's working files** to "improve" them unless the current task requires it — flag suggested improvements instead of making them silently.
6. **If something in this spec is ambiguous or seems to conflict with itself, stop and ask** rather than guessing — this spec has already been through one correction pass; a second contradiction is more likely a real oversight worth catching.

---

## 11. Compliance Requirements (⚠ FIX — mostly missing in original)

This is a child-directed app on Google Play, which has specific mandatory rules that a "must comply with applicable policies" line does not actually cover. Concretely, before submission:

- **Google Play Families Policy**: complete the "Target audience and content" declaration in Play Console honestly (ages 2–6 falls under "Families" — this triggers stricter review).
- **Privacy Policy**: required even with zero data collection. A simple static page stating "this app collects no personal data and requires no account" is enough for V1 (host it free on GitHub Pages or similar) — but it must exist and the link must work before submission, not be a placeholder.
- **Data Safety form** (Play Console): since V1 has no accounts, no analytics, no ads, and no network calls, this form should be straightforward to fill honestly — but it is a required, human-reviewed step, not something the agent can complete for you.
- **No ad SDK, no analytics SDK, no crash-reporting SDK** in V1 — every one of these has separate children's-privacy certification requirements (e.g. Google Play's Families Ads Program) that are out of scope for a first release. Revisit only in a version where monetization is deliberately being added, and treat SDK selection as its own research task at that time.
- **COPPA** (if publishing with U.S. availability): a no-account, no-network, no-ads app has a much smaller compliance surface, but you should still read Google's current Families Policy requirements yourself before submission — this PRD is not legal advice.

---

## 12. Deferred to V1.1+ (explicitly, so it's not forgotten but also not attempted now)

- Custom mascot design and illustrated game assets (replacing emoji)
- Difficulty selector (Easy/Normal/Challenge)
- Voice narration (TTS or recorded audio for word pronunciation)
- Numbers, ABC, Memory, Puzzles, Coloring categories
- Any monetization (ads, Unlock All) — requires its own compliance research pass first (Section 11)
- Multiple languages, parent dashboard, character customization

---

## 13. Definition of Done — V1 Release Checklist

- [ ] Home screen shows all 5 categories
- [ ] All 5 games fully playable, 10 questions each
- [ ] Choices always shuffled — correct answer position varies
- [ ] Wrong answer keeps child on the same question with "Try again!"
- [ ] Correct answer shows a rotating positive phrase + star increment
- [ ] Star totals persist across app restart (Section 6)
- [ ] Sound plays for correct/wrong/complete, and can be muted in Parent Area
- [ ] Parental gate (math check) blocks access to Parent Area
- [ ] App fully playable in airplane mode
- [ ] No crashes on a budget-tier device/emulator and a large-screen device/emulator
- [ ] Portrait orientation locked
- [ ] Privacy Policy page live and linked from Parent Area
- [ ] Play Console Data Safety form and Target Audience declaration completed honestly
- [ ] Store listing (title, short description, screenshots) prepared

---

## 14. Future Roadmap (kept from original, unchanged)

- **V1.1:** more questions, better animations, real mascot + illustrated assets, difficulty selector
- **V1.2:** Numbers, ABC, Counting, Memory
- **V1.3:** Coloring, simple puzzles, tracing
- **V2:** multiple characters, progress system, parent dashboard, multiple languages
- **V3:** Stories, Songs, animations, YouTube content, character universe
