# Vice City Mobile — Godot cross-platform rebuild

Independent open-world game project for Web and Android. It is inspired by the genre and is not affiliated with Rockstar Games or using proprietary GTA assets.

## Open the project
Open this `godot/` folder in Godot 4.4 or newer. The main scene is `scenes/main.tscn`.

## Systems currently authored in this branch
- Shared Godot project configured for Web and Android with the Compatibility renderer.
- Animated main menu and a mobile controls help screen.
- Third-person player controller with keyboard and touch input.
- Touch joystick on the bottom-left and camera drag on the right.
- Procedural articulated player visual with idle/walk/run movement.
- First coastal district with road grid, lane markings, sidewalks, Art-Deco-inspired towers, promenade, beach, palms and street furniture.
- Six small parks with real CC0 Quaternius tree and shrub GLB models, benches and paths.
- Twelve lightweight traffic vehicles moving along the road grid.
- Fourteen lightweight pedestrians following sidewalk routes.
- One drivable car with curved custom mesh body, four suspension wheels, keyboard/touch steering, throttle, brake, and enter/exit interaction.
- Five-level wanted heat meter, triggered by high-speed driving and traffic impacts, with simple police pursuit units.
- Three non-combat delivery missions with glowing waypoints and cash rewards.
- Persistent mission progress, cash, engine upgrades and vehicle paint.
- In-game shop/garage panel for engine upgrades and paint purchases.
- Live minimap showing roads, coast, player, vehicle, and current objective.
- Web and Android export presets, plus a GitHub Actions workflow intended to validate the project and export a browser build.

## Important scope and limitations
This is an early game slice, not a finished GTA-scale open-world game. The current district is a compact first area, not a massive map. The player, pedestrians, traffic and police visuals are procedural stand-ins, not final motion-captured or production-quality character assets. Traffic follows simple fixed road routes; pedestrians follow simple sidewalk loops; police pursuit is a basic direct-follow system. There is no full campaign, combat system, functional building interiors, advanced NPC schedules, vehicle dealership, multiplayer, or save slots yet.

The project has not yet been successfully run in the Godot editor or tested on an Android device in this work session. The target of 60 FPS on entry-level phones is a performance goal, not a measured result. No APK or hosted Web build should be considered ready until CI/export and device/browser tests pass.

## Controls
- Desktop: WASD or arrow keys to move; Shift to run; E to enter/exit the nearby car; Space to brake.
- Touch: left joystick to move or steer/accelerate; drag the right side to rotate the camera; hold CORRER on foot or FREIO in the car.
- ENTRAR/SAIR appears near the vehicle.
- LOJA / GARAGEM opens the purchase panel.
- Driving fast or colliding with traffic raises the wanted level. Slow down and stay out of pursuit to let heat cool.
- Drive into the glowing objective ring to finish a delivery and earn cash.

## Export
The `export_presets.cfg` file includes Web and Android presets. The Android export is configured for arm64. The GitHub Actions workflow imports the project, runs it headlessly, exports Web and stores the build as an artifact. Exported builds have not yet been packaged or device-tested.

## Asset license
The vegetation GLB models are from the Quaternius Stylized Nature MegaKit and are distributed as CC0 1.0 assets. See `assets/vegetation/CREDITS.md`. The source Quaternius page also lists Universal Base Characters and Animation Library as CC0; those production character assets are not yet integrated.
