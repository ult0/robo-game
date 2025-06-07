# RPG Game

A Godot-based tactical RPG framework featuring unit spawning, selection, movement, and preview layers. The project is designed with a modular architecture for easy extension and customization of units, levels, and gameplay systems.

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
