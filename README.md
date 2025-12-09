# Gemini Shooter

A space shooter game for Atari 8-bit XL/XE computers, written by GitHub Copilot AI Agent in Mad Pascal.

## About the Game

📖 **[Read the full story about how this game was created →](docs/THE_STORY.md)**

## Description

This game is inspired by the AI-generated game project described on AtariOnline.pl, where Gemini 3 Pro was used to create a complete Atari 8-bit game. This Mad Pascal implementation showcases:

- **PMG (Player/Missile Graphics)** for hardware sprites (player ship and enemies)
- **Custom Display List** with mixed text/graphics modes
- **DLI (Display List Interrupts)** for colorful gradient effects
- **Scrolling star background** for space atmosphere
- **Sound effects** for shooting, explosions, and megabomb
- **Megabomb special weapon** - clears all enemies from screen
- **Score tracking and level progression**

## Features

- Player ship controlled via joystick
- Multiple enemies with AI movement patterns
- Collision detection using hardware and software methods
- Progressive difficulty (faster enemies at higher levels)
- Title screen with instructions
- Game over screen with final score

## Controls

- **Joystick**: Move player ship (8 directions)
- **Fire Button**: Shoot missile
- **Space/M Key**: Activate Megabomb (limited use)

## Building

### Prerequisites

1. FreePascal Compiler (fpc) - for compiling the tools
2. Mad Pascal compiler (compiled from source)
3. MADS assembler (compiled from source)

### Compile Tools (if not already done)

```bash
# Compile Mad Pascal
cd MAD_Pascal/Mad-Pascal-1.7.3/src
fpc -Mdelphi -vh -O3 mp.pas

# Compile MADS
cd MAD_Pascal/Mad-Assembler-2.1.6
fpc -Mdelphi -vh -O3 mads.pas
```

### Build the Game

```bash
cd GeminiShooter
./build.sh
```

If your Mad Pascal and MADS are in different locations, set environment variables:

```bash
export MP_PATH=/path/to/Mad-Pascal
export MADS_PATH=/path/to/Mad-Assembler
./build.sh
```

The compiled game will be in `builds/GeminiShooter.xex`.

## Running

Load the `.xex` file in an Atari 8-bit emulator:
- Altirra (recommended)
- Atari800
- Or on real hardware via SIO2SD, FujiNet, etc.

## Technical Details

- **Memory Layout**:
  - PMG Base: $A000
  - Display List: $A800
  - Screen Memory: $BC00
  
- **Graphics Mode**: ANTIC Mode 2 (40x24 text) with custom display list

- **Sprites**:
  - Player 0: Player ship
  - Players 1-2: Enemies
  - Missiles: Player bullets

## References

Based on techniques from:
- "De Re Atari" - Classic Atari programming reference
- "Altirra Hardware Manual" - Detailed hardware documentation
- "Poradnik programisty Atari" by Wojciech Zientara
- Mad Pascal examples from https://github.com/tebe6502/Mad-Pascal

## License

This game is provided for educational purposes, demonstrating Mad Pascal programming for Atari 8-bit computers.

## Credits

- Mad Pascal compiler by Tebe/Madteam
- MADS assembler by Tebe
- blibs library by Bocianu
- Inspired by the Gemini 3 Pro Atari game project by Nosty/GR8 Software
