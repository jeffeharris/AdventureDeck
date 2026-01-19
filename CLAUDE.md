# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AdventureDeck is an iOS SwiftUI app for children (ages 3-5) featuring themed adventure maps with procedural generation, a scanner/discovery system, passive missions, and AR camera scanning. The app has four themes: Space, Ocean, City, and Western.

**Target:** iOS 17.0+, iPhone/iPad, Landscape orientation only

## Build Commands

Open in Xcode and build (Cmd+B) or run (Cmd+R). No external dependencies - pure SwiftUI.

```bash
# Open project
open AdventureDeck.xcodeproj
```

## Architecture

**Pattern:** MVVM with Swift Observation framework (`@Observable` macro)

**Core Flow:**
```
AdventureDeckApp (@main)
  └── AdventureViewModel (@Observable, @MainActor) injected via .environment()
        ├── State: theme, map, travel progress, missions, scanner
        ├── Managers: AudioManager, MapGenerator, DiscoveryManager
        └── Timers: travel (60fps), events, missions
```

**State Machine:** `AdventureState` enum drives UI:
- `selectingTheme` → ThemeSelectorView
- `ready/traveling/paused/arrived` → AdventureView (MapView + controls)

## Key Components

| Component | Purpose |
|-----------|---------|
| `AdventureViewModel` | Central state coordinator - all game logic flows through here |
| `MapGenerator` | Procedural map creation: terrain zones → nodes → paths → traversal route |
| `DiscoveryManager` | Generates themed discoveries, persists to UserDefaults |
| `Theme` enum | Defines colors, icons, sounds, terrain types per theme |
| `Mission` | Passive missions that drift in/out without pressure |

## Important Patterns

**Timer Management:** ViewModel owns all timers. Always invalidate in `stopAdventure()` and state transitions.

**Map Generation Order:**
1. Generate terrain zones (3x2 grid, no adjacent duplicates)
2. Place nodes in grid-distributed pattern
3. Connect nearby nodes with paths
4. Find longest traversal path via DFS

**Scanner Flow:** `idle` → `scanning(position)` → `showingResult(discovery)` → `idle`

**Mission Flow:** `none` → `available` (auto-fades after 30s if ignored) → `active` → `celebrating` → `none`

## File Organization

- `Models/` - Data structures (Theme, Mission, Discovery, AdventureMap, TerrainZone)
- `Managers/` - Services (AudioManager, MapGenerator, DiscoveryManager)
- `Views/` - SwiftUI views organized by feature (Scanner/, Missions/, AR/)
- `Resources/` - Assets.xcassets and Sounds/

## Persistence

Only `DiscoveryCollection` persists via UserDefaults key `AdventureDeck.DiscoveryCollection`. All other state resets on app restart.

## Child-Friendly Design Constraints

- Large tap targets (minimum 60pt)
- No fail states or penalties
- Missions are passive/ambient - ignored missions simply fade away
- Simple single-tap interactions
- Bright colors and playful animations
