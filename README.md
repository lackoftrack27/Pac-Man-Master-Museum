# Pac-Man Master Museum

An **accuracy-focused** conversion of *Pac-Man* and *Ms. Pac-Man* for the Sega Master System.

---

## Features
- **High Accuracy:** The games play just like the originals. 
  - The Ghost AI is faithfully replicated. Patterns for the originals can be executed here as well. *(Not 100% verified)*
  - Sound effects and music are as accurate as possible given the limitations of the SN76489, the Master System's sound chip.
- **Game Selection:** Choose between *Pac-Man* and *Ms. Pac-Man* by pressing left or right on the title screen.
  - Press **Button 2** to play the *Plus* variants.
- **Customizable:** Difficulty, life count, bonus life, and other settings are fully configurable in the options menu.
  - The popular speed-up mode can be toggled in the options menu as well.
- **Two Graphic Styles:**
  - **Smooth** – Adds extra detail and color utilizing the Master System’s superior graphical capabilities.
  - **Arcade** – Faithfully replicates the original arcade look as close as possible.
- **1–2 Player Support**

---

## About the Project
This started as a personal project to learn Z80 assembly. My long-term goal was to create a Pac-Man Collection featuring *Pac-Man*, *Ms. Pac-Man*, and *Pac-Man Plus*, inspired by Opcode Games’ Colecovision release.

My key inspirations for this project were:
- *Pac-Man Collection* by **Opcode Games**
- *Ms. Pac-Man Classic* by **xfixium**
- *Pac-Man Emulator* by **Simon Owen**
- *Pac-Man* by **masonicGIT**

I hope this code is useful for anyone interested in learning Z80 assembly or exploring how *Pac-Man* works internally.

---

## Credits
This project wouldn't nearly be as polished without the help of these people:
- **scratch125** – Art, sound, and general guidance
- **umjammercammy** – Art and general guidance

Additional Credits:
- **Einar Saukas** - ZX7 compression algorithm used here to compress graphics and tilemaps

---


## Changelog
**v2.00**
- Added Ms. Pac-Man and Ms. Pac-Man Plus (Ms. Pac-Man Plus is a hack that brings Pac-Man Plus's unique mechanics to Ms. Pac-Man)
- Added "Arcade" graphical style which tries to imitate the original games' style as close as possible
- Touched up the now "Smooth" style sprites
- Changed the smaller font to a more readable one
- Improved sound effects
- Changed game name to better reflect its contents
- Revamped Options Menu for a cleaner look
- Added Sound Test to the Options Menu
- Added Mega Drive / Genesis controller support. Player 1 can now pause with the Start button
- Plenty of bugfixes
- Improved ghost AI

**v1.10**
- Options do not reset any more when you go into the options menu. They are now only reset on cold boot
- Default life count has been changed to 3
- Fixed a bug where the ghost would sometimes flicker in cutscenes
- Game can now only be paused when player is in control of Pac-Man
- Rewrite of the sound driver to allow for volume envelopes
- Some sprites improved
- Some sound effects and music improved

**v1.00 hotfix**
- There was a visual bug in the second cutscene that was caused by a change in how sprites are made invisible. It has been fixed

**v1.00**
- Added Introduction and Demo. Wait 10 seconds at title screen to see
- Added all cutscenes
- Fixed a bug where an extra life was given only if the player surpassed the score required, not at
- Changed dot eating SFX. It should sound a bit closer to the original
- Added original game's RNG function used for scared ghost movement
- Improved sprite flicker code. Pac-Man should now never flicker
- Reduced ROM size to 32KB
- Code optimization everywhere!
- The big one: added Pac-Man Plus. Press Button 2 at title screen to activate

**v0.95**
- Fixed "stuck" dots that would appear if the player had died while eating them
- Fixed second player mode not initializing some variables when switching between players
- Fixed unnecessary sprite flickering on real hardware
- Fixed Genesis/Mega Drive incompatibility (or at least it didn't work on mine)
- Improved Ghost AI, should be just about perfect now
- Probably some other minor bugs that I forgot about

**v0.90**
- Initial release
