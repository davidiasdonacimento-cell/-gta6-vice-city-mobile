# Vice City Mobile — Godot cross-platform rebuild

Independent open-world project for Web and Android. It is not affiliated with Rockstar Games and does not use proprietary GTA assets.

## Open the project
Open this `godot/` folder in Godot 4.4 or newer. The main scene is `scenes/main.tscn`.

## Current foundation
- One Godot project intended for Web and Android exports.
- Compatibility renderer for the shared WebGL/mobile rendering path.
- Third-person player controller with keyboard and touch input.
- Touch joystick on the bottom-left and camera drag on the right.
- Articulated placeholder character with procedural idle/walk/run movement.
- First coastal district: road grid, lane markings, sidewalks, art-deco-inspired rounded towers, waterfront promenade, beach strip, palms and street furniture.
- Collision for the player ground and building footprints.

## Current limitations
This is a playable foundation and first district, not a finished large open-world game. The character is a procedural placeholder, not a production rigged/animated GLB. Buildings are generated from Godot meshes; they are not hand-authored Blender assets. There are not yet drivable vehicles, traffic, pedestrian AI, missions, interiors, save/load, audio, or a complete map.

## Controls
- Desktop: WASD or arrow keys to move; Shift to run.
- Touch: left virtual joystick to move; drag on the right half to rotate the camera; hold CORRER to run.

## Export
Create an HTML5 export preset in Godot for Web deployment. Create an Android export preset and configure the Android SDK for APK generation. Both exports use this same project. Exported builds have not yet been packaged or device-tested.
