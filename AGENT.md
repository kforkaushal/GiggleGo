# AGENT.md — Giggle Go! Agent Guardrails

These rules apply in every agent session. Re-read this file at the start of each session.

## Rules (from PRD Section 10)

1. **One phase at a time.** Do not start Phase N+1 until Phase N's Definition of Ready is confirmed by the user.

2. **Ask, don't assume, for:**
   - The 3 sound files (`correct.mp3`, `wrong.mp3`, `complete.mp3`) — needed before Phase 4
   - Anything in PRD Section 2's "V1 IS NOT" list if it seems tempting to add "while you're in there"

3. **Commit to git after every phase**, with message format: `Phase N: <description> complete`

4. **Never introduce a new package** not in PRD Section 4 without stopping to ask first.
   - Allowed packages: `audioplayers: ^6.0.0`, `shared_preferences: ^2.2.0`

5. **Never touch a previous phase's working files** to "improve" them unless the current task requires it — flag suggested improvements instead.

6. **If spec is ambiguous or conflicts with itself, stop and ask** rather than guessing.

## V1 IS NOT List (do not add these)
- Custom illustrated art / mascot artwork
- Difficulty selector UI (Easy/Normal/Challenge)
- Numbers, ABC, memory, puzzles, coloring categories
- Ads, in-app purchases, "Unlock All" logic
- Firebase, accounts, cloud sync
- Voice narration (TTS)
- Custom fonts requiring licensing research

## State Management Rule
Plain `StatefulWidget` + `setState` only. No Riverpod, Bloc, or Provider.

## App ID
`com.dev.gigglego`
