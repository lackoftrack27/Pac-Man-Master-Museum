# Pac-Man Master Museum

An **accuracy-focused** conversion of *Pac-Man*, *Ms. Pac-Man*, and *Jr. Pac-Man* for the Sega Master System.

**Download Here:** https://www.smspower.org/Homebrew/Pac-ManMasterMuseum-SMS

---

## Features
- **High Accuracy:** The games play just like the originals. 
  - The Ghost AI is faithfully replicated. Patterns for the originals can be executed here as well. *(Not 100% verified)*
  - Sound effects and music are as accurate as possible given the limitations of the SN76489, the Master System's sound chip.
- **Game Selection:** Choose between *Pac-Man*, *Ms. Pac-Man*, and *Jr. Pac-Man* by pressing left or right on the title screen.
  - Press **Button 2** to play the *Plus* variants.
  - There's a *crazy* surprise game awaiting as well! 
- **Customizable:** Difficulty, life count, bonus life, and other settings are fully configurable in the options menu.
  - The popular speed-up mode can be toggled in the options menu as well.
- **Two Graphic Styles:**
  - **Smooth** – Adds extra detail and color utilizing the Master System’s superior graphical capabilities.
  - **Arcade** – Faithfully replicates the original arcade look as close as possible.
- **1–2 Player Support**
- **High Score Saving**


---

## About the Project
This started as a personal project to learn Z80 assembly. My long-term goal was to create a Pac-Man Collection featuring *Pac-Man*, *Ms. Pac-Man*, and *Pac-Man Plus*, inspired by Opcode Games’ Colecovision release.

My key inspirations for this project were:
- [*Pac-Man Collection*](https://cvaddict.com/profile.php?gameid=157) by **Opcode Games**
- [*Ms. Pac-Man Classic*](https://www.smspower.org/Homebrew/MsPacManClassic-SMS) by **xfixium**
- [*Pac-Man Emulator*](https://simonowen.com/articles/pacemu/) by **Simon Owen**
- [*Pac-Man*](https://github.com/masonicGIT/pacman) by **masonicGIT**

I hope this code is useful for anyone interested in learning Z80 assembly or exploring how *Pac-Man* works internally.

---

## Credits
This project wouldn't nearly be as polished without the help of these people:
- **125scratch** – Art, sound, and general guidance
- **umjammercammy** – Art and general guidance
- **Superjustinbros** - Maze palettes for Ms. Pac-Man Plus and Jr. Pac-Man Plus 

Additional Credits:
- **Einar Saukas** - [ZX7 compression](https://spectrumcomputing.co.uk/entry/27996/ZX-Spectrum/ZX7) algorithm used here to compress graphics and tilemaps
- **Maxim** - [BMP2Tile](https://github.com/maxim-zhao/bmp2tile)

---


## Changelog
**v3.10**
- Fixed bug in Jr. Pac-Man where normal pellets sometimes awarded 50 points instead of 10
- Fixed bug in Jr. Pac-Man where, if a fruit was eaten just before it exploded a power pellet, eating that pellet would sometimes cause the wrong one to disappear
- Fixed bug in Jr. Pac-Man where ghost scatter mode wasn't properly random for Blinky, Pinky, and Inky
- Added more definition to the cherry, strawberry, apple, and pear fruit sprites for smooth style
- Added more definition to the balloon and Yum-Yum sprites for smooth style

**v3.00**
- Added Jr. Pac-Man and Jr. Pac-Man Plus
	- They feature a larger viewable area compared to the original at the cost of some ghost AI accuracy
- Added SRAM support for high scores
	- 12 high scores in total
		- 4 for each game (Non Plus/Normal), (Non Plus/Fast), (Plus/Normal), (Plus/Fast)
	- Saves upon Game Over
- Added IGR button combo for MD/Genesis controllers (Start + A + B + C)
- Minor corrections to ghost AI
- Changed maze palettes in Ms. Pac-Man Plus to be more appealing
- Added minor edits to Ms. Pac-Man's sprites and Jr. Pac-Man's sprites for their Plus mode
- Tweaked some of Ms. Pac-Man's songs to be a bit more accurate
- Added Crazy Otto as a bonus game
	- Crazy Otto is one of the many iterations Ms. Pac-Man went through before starring one of gaming's most famous icons
	- Features a completely different cast: Otto, "Plato", "Darwin", "Freud", "Newton", and Anna
	- Gameplay is almost identical to Ms. Pac-Man except ~ 
		- Freud and Newton, (Inky and Clyde), have random movement during Scatter Mode
		- Monsters turn invisible when eaten instead of only having their eyes visible. The accompanying sound effect does not play either

**v2.20**
-   Fixed a bug where the ghosts wouldn't be eaten during Pac-Man's introduction.
-   Fixed the 6th fruit sprite on the HUD for Ms. Pac-Man Plus.
-   Properly initialized player inactivity timer.

**v2.10**
- Fixed a bug where the player could still die after eating the last dot
- Fruit timer now decrements when eating a ghost
- Fixed a bug where Blinky would incorrectly show through the transparent pixels of the fruit sprites in Pac-Man’s third cutscene
- Fixed a bug where the ghost score points sprite would be shown instead of Pac-Man in cutscenes if the player managed to finish a level while eating a ghost

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
