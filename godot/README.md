# Vice City Mobile — Godot cross-platform rebuild

Independent open-world game project for Web and Android. It is not affiliated with Rockstar Games and does not use proprietary GTA assets.

## Open the project
Open this `godot/` folder in Godot 4.4 or newer. The main scene is `scenes/main.tscn`.

## Implemented in this branch
- One Godot project intended for Web and Android exports, using the Compatibility renderer.
- Third-person controller with keyboard and touch input.
- Touch joystick on the bottom-left and camera drag on the right.
- Articulated player placeholder with procedural idle/walk/run movement.
- First coastal district with a road grid, lane markings, sidewalks, rounded Art-Deco-inspired towers, promenade, beach, palms and street furniture.
- Six small city parks using real CC0 Quaternius tree and shrub GLB models, with benches and paths.
- Palm geometry batched with MultiMesh to reduce draw calls.
- First drivable car using VehicleBody3D, four suspension wheels, keyboard/touch steering, throttle, brake, and enter/exit interaction.
- Three non-combat delivery missions with glowing waypoints and cash rewards.
- Live minimap showing the road grid, coast, player heading, vehicle, and current objective.
- Ground and building collision, plus a vehicle and player controller.

## Current limitations
This is an early playable game slice with a first district, not a finished large open-world game. The player and car visuals are still procedural placeholders; most buildings are generated from Godot meshes. There are not yet pedestrian AI, traffic simulation, a full mission campaign, functional shops/interiors, save/load, or spatial audio. The Godot project has not yet been successfully run in the editor or tested on an Android device in this work session.

## Controls
- Desktop: WASD or arrow keys to move; Shift to run; E to enter/exit the nearby car; Space to brake.
- Touch: left joystick to move or steer/accelerate; drag the right side to rotate the camera; hold CORRER on foot or FREIO in the car.
- The ENTRAR/SAIR button appears when close to the vehicle.
- Drive into the glowing objective ring to finish a delivery and earn cash.

## Export
Create an HTML5 export preset in Godot for Web deployment. Create an Android export preset and configure the Android SDK for APK generation. Both exports use this same project. Exported builds have not yet been packaged or device-tested.

## Asset license
The vegetation GLB models are from the Quaternius Stylized Nature MegaKit and are distributed as CC0 1.0 assets. See `assets/vegetation/CREDITS.md`. The source Quaternius page also lists the Universal Base Characters and Animation Library as CC0, but they are not yet integrated in this build.
