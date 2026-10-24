# Game Client Improvement Todo

Comparison of `game_client/` against [Architecture_plan.md](./Architecture_plan.md) and [Directory_tree.md](./Directory_tree.md).

## Current-state comparison

| Area | Documented target | Observed in `game_client/` |
| --- | --- | --- |
| Project layout | `autoload/`, `analytics/`, `scenes/`, `ui/`, and categorized assets | Authored code is mainly in `Scripts/` and `Scenes/`; assets are split among `assets/fonts`, `images`, `sprite`/`Sprites`, `Icon`, `styles`, and `Themes`. The documented paths do not match the current `res://` layout. |
| World and player | `BaseWorldScene`, `BasePlayer`, tutorial and investigation world scenes | `Scripts/Player.gd` and `Scenes/Initial/player.tscn` exist, but `Scenes/Scene_02_Tutorial.tscn` is only a centered label. No `BaseWorldScene.gd` or `BasePlayer.gd` is present. |
| Overlays and OS UI | Reusable overlay/OS-window bases, communication and evaluation overlays, and named desktop scenes | A working menu/settings flow and a custom desktop screen/window/icon implementation exist. The documented `BaseOverlayUI`, `BaseOSWindow`, phone/chat/call/checklist/KSA scenes, and named desktop scenes are absent. |
| Puzzles | Four puzzle base classes plus nine task scenes | Five puzzle scene files exist, but sampled scenes are label-only placeholders and no puzzle scene has an attached script. The base classes and four planned scenes (file structure, decoder, persistence order, and final summary) are absent. |
| Telemetry | Manager plus network adapter and typed DTO hierarchy | `Scripts/TelemetryManager.gd` has basic timer/event methods and an HTTP request, but no separate adapter or DTO classes are present. The backend URL and player ID are hardcoded to local/test values; no gameplay or scene scripts call its tracking methods. |
| Story flow and persistence | Intro, tutorial, incident, investigation, desktop, and recovery sequence | The intro cutscene and parts of the desktop simulation are implemented. Incident, investigation-world, and recovery scenes are absent. The Continue modal currently routes to one puzzle rather than restoring saved progress. |
| Validation | Not specified in the architecture documents | No project-owned test directory or automated scene-flow checks were observed in the authored client files. |

## Prioritized backlog

### P0 — Align the implementation target

- [ ] **Reconcile the architecture documents with the current project.** Decide whether to adopt the documented `autoload/analytics/scenes/ui` layout or update the documents to describe the existing `Scripts/Scenes/assets` layout. Record which of the planned scenes and classes are in scope for this release. Avoid a mechanical rename until the `res://` references and scene-flow decisions are agreed.

### P1 — Build a playable, testable vertical slice

- [ ] **Implement the tutorial world and player integration.** Create the world/player base behavior from the architecture, use the existing player scene/script where appropriate, and replace the label-only `Scenes/Scene_02_Tutorial.tscn` with a playable tutorial. Include player spawn, movement boundaries, interaction handling, and an end condition.
  - Depends on: P0.
- [ ] **Implement the puzzle framework and complete the first puzzle path.** Add the shared puzzle contract (task ID, attempts, answer validation, resolution, and hint state), then turn the existing Drive History scene into a functional puzzle with success/failure handling. Apply the same contract to the other existing puzzle scenes.
  - Depends on: P0.
- [ ] **Complete the planned puzzle set.** Implement Event Log, Hash Verify, Typing Game, and 3-2-1 Backup behavior; add File Structure, Decoder, Persistence Order, and Last Boss Summary scenes and behavior. Connect each puzzle to the shared result/telemetry flow.
  - Depends on: puzzle framework.
- [ ] **Add project-owned automated checks.** Cover puzzle answer/attempt behavior and the main scene route; add a Godot headless project/scene-load smoke check so missing resources and broken scene references are caught early.
  - Depends on: the vertical slice and puzzle framework.

### P1 — Bring planned architecture capabilities online

- [ ] **Define and implement the telemetry contract.** Confirm the backend schema and deployment configuration; move URL/player identity out of test constants; add the planned network adapter and DTO types; surface request/parse failures and prevent overlapping requests from being silently lost.
  - Depends on: backend contract confirmation.
- [ ] **Instrument gameplay and puzzle events.** Call telemetry from player interaction, story transitions, and puzzle start/submit/success/failure; include timing, attempts, hint use, and session identifiers. Verify payloads against the backend contract.
  - Depends on: telemetry contract and playable flows.
- [ ] **Extract reusable overlay and OS-window contracts.** Identify common behavior in the existing settings/menu and desktop implementations, then introduce only the base classes needed by real screens. Add the missing phone/chat/call/dialogue/checklist/evaluation and desktop screens as their story tasks become playable.
  - Depends on: P0 and the scene-flow scope decision.
- [ ] **Implement the rest of the story route.** Add the incident, investigation, desktop, and recovery transitions and connect the existing intro and desktop implementations without duplicate or unreachable entry points.
  - Depends on: tutorial and puzzle flow; coordinate with overlay and desktop tasks.

### P2 — Make the project easier to maintain and release

- [ ] **Standardize authored file names and locations.** After the layout decision, standardize directory and script naming/casing and update all scene/resource references. Keep the Godot add-on separate from game-owned code.
  - Depends on: P0.
- [ ] **Implement actual save/continue behavior.** Persist progress and let Continue resume from a valid saved state instead of always opening the same puzzle; cover missing or invalid save data.
  - Depends on: story-flow and puzzle progression state.
- [ ] **Validate release configuration.** Test a clean import and launch, confirm required assets and external service settings, and document local/backend configuration and the supported Godot version.
  - Depends on: automated checks and telemetry configuration.
