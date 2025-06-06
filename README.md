# RPG Game

<!-- Add description here -->

## Project Structure

```
src/
|
├── core/
│   ├── game_state/
│   ├── global/
│   ├── managers/
│   │   ├── camera/
│   │   ├── input/
│   │   ├── layers/
│   │   ├── level/
│   │   ├── spawners/
│   │   └── unit/
│   └── utils/
│       ├── a_star/
│       ├── priority_queue/
│       └── state_machine/
│
├── entities/
│   └── units/
│       ├── base/
│       ├── components/
│       ├── enemy/
│       └── player/
│
├── data/
│   ├── constants/
│   ├── presets/
│   │   └── units/
│   └── resources/
│
├── ui/
│   ├── components/
│   ├── hud/
│   │   ├── selected_unit_display/
│   │   └── selector/
│   └── menu/
│
├── world/
│   └── levels/
│
└── assets/
    ├── audio/
    ├── fonts/
    ├── sprites/
    └── themes/

tests/
└── ...

addons/
├── layerNames/
└── ...
```
