# Vice City Mobile — Godot cross-platform rebuild

This is a **separate Godot 4 project** under `godot/`. The existing Vite/Three.js deployment is intentionally left untouched while this rebuild is developed.

## Targets
- Web: Godot Web export (WebAssembly/WebGL 2), suitable for static hosting such as Render.
- Android: native APK export from the same Godot project.
- Renderer: Compatibility renderer to keep the Web and Android rendering paths aligned.

## Open
Open the `godot/` folder in Godot 4.4 or newer and run `scenes/main.tscn`.

## Important status
This commit establishes the cross-platform project structure and input/controller foundation. It is **not a finished GTA-scale game** and does not yet contain production character, vehicle, city, mission, traffic, or interior assets. The temporary capsule is only a controller placeholder; it must be replaced with an original rigged character and animation set before calling the character system complete.

## Production sequence
1. Import licensed/original character, animation, vehicle, environment and prop assets.
2. Build authored city districts, roads, collision, streaming and LOD.
3. Add vehicle physics, traffic/pedestrians, mission framework, save system and audio.
4. Export and test Web build on Android Chrome and native Android APK on-device.
5. Keep Web and Android controls, performance budgets and UI parity.
