# Vice City Mobile — Godot cross-platform rebuild

Independent open-world project for Web and Android. It is not affiliated with Rockstar Games and does not use proprietary GTA assets.

## Open the project
Open this `godot/` folder in Godot 4.4 or newer. The main scene is `scenes/main.tscn`.

## Implemented in this branch
- One Godot project intended for Web and Android exports, using the Compatibility renderer.
- Third-person player controller with keyboard and touch input.
- Touch joystick on the bottom-left and camera drag on the right.
- Articulated player placeholder with procedural idle/walk/run movement.
- First coastal district with a road grid, lane markings, sidewalks, rounded Art-Deco-inspired towers, promenade, beach, palms and street furniture.
- Six small city parks using real CC0 Quaternius tree and shrub GLB models, with benches and paths.
- Palm geometry batched with MultiMesh to reduce draw calls.
- First drivable car using VehicleBody3D, four suspension wheels, keyboard/touch steering, throttle, brake, and enter/exit interaction.
- Collision for the ground, buildings, player, and vehicle.
- A live minimap showing the road grid, coast, player heading, and vehicle.

## Current limitations
This is an early game foundation with a first district, not a finished large open-world game. The player and car visuals are procedural placeholders, and most buildings are generated from Godot meshes rather than production Blender assets. There are not yet pedestrian AI, traffic simulation, missions, functional shops/interiors, save/load, or spatial audio. All systems still require an editor run and device testing.

## Controls
- Desktop: WASD or arrow keys to move; Shift to run; E to enter/exit the nearby car.
- Touch: left joystick to move or steer/accelerate; drag the right side to rotate the camera; hold CORRER on foot or FREIO in the car.
- The ENTRAR/SAIR button appears when close to the vehicle.

## Export
Create an HTML5 export preset in Godot for Web deployment. Create an Android export preset and configure the Android SDK for APK generation. Both exports use this same project. Exported builds have not yet been packaged or device-tested.

## Asset license
The vegetation GLB models are from the Quaternius Stylized Nature MegaKit and are distributed as CC0 1.0 public-domain assets. See `assets/vegetation/CREDITS.md`.
