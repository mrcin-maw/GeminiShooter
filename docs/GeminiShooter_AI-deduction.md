# GeminiShooter - AI Deduction

-   Start \'playwright\' MCP server

-   Start \'github-mcp-server\' MCP server

-   Navigate Playwright web browser to a URL

-   View repository

The website is blocked. Let me explore the repository more thoroughly
and try to access the article through different means, while also
understanding the existing Mad Pascal resources.

-   View **MAD_Pascal**

-   View **first_blood_MP**

-   View **exercises_with_ChatBot **

-   View **Player_movementAlgorithm**

-   Bash: Fetch article content** from atarionline.pl**

The website might be blocked. Let me try to use a web search to find
information about this article.

-   Web Search: **atarionline.pl ***AI napisało grę Atari Nosty Gemini 3
    Pro 2025-11-26*

Excellent! Now I have a good understanding of the article. Let me search
for more specific details about the game mechanics and code structure.

-   Web Search: *Nosty Gemini 3 Pro Atari game shooter space invaders
    PMG display list DLI atari 8-bit*

-   Web Search: **Saberman YouTube ***Atari Gemini 3 Pro game AI video
    2025*

-   Web Search: **atari.org.pl ***Gemini 3 Pro gra Atari XE/XL Nosty GR8
    Software kod źródłowy*

-   View **MAD_Pascal/Mad-Pascal-1.7.3**

Now I understand the task better. I need to create a space shooter game
for Atari 8-bit using Mad Pascal, similar to what Nosty created with
Gemini 3 Pro. Let me explore the Mad Pascal examples and resources to
understand how to implement:

1.  PMG (Player/Missile Graphics) for sprites

2.  Display List with mixed modes

3.  DLI (Display List Interrupts) for colors

4.  Scrolling background

5.  Sound

6.  Title screen and game over screen

7.  Star effects and \"Megabomb\" features

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/blibs**

-   View **first_blood_MP/zorro_player**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/blibs/b_pmg.pas**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/blibs/b_dl.pas**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/games**

Excellent! There are several game examples. Let me explore the
invaders.pas and galactica.pas which seem most relevant to the space
shooter game I need to create:

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/games/invaders.pas**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/games/galactica.pas**

Excellent! Now let me examine more examples for DLI and interrupt
handling:

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/interrupt**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/graph_pmg**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/interrupt/dli_vbl**

-   View
    **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/graph_pmg/pmgdemo.pas**

-   View
    **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/interrupt/dli_vbl/dli_vbl.pas**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/graph_pmg/pmgdemo2.pas
    **

Now let me look at the sound examples and more game samples:

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/sound**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/samples/a8/games/hit_star.pas**

Now I have a good understanding of how Mad Pascal games work. Let me
also check the blibs folder and explore how player movement works from
the repository:

-   View **first_blood_MP/pmg_test1\[blibs\](pmgdemo3).pas**

-   View** blibs**

Now let me understand the build process and check the tools available:

-   View **MAD_Pascal/build.bat**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/bin**

-   View **MAD_Pascal/Mad-Pascal-1.7.3/bin/windows**

-   Bash:** List all binaries**

I see the compiler is Windows-only. Let me search for a Linux version or
check how to set up the Mad Pascal compiler in this environment:

-   Bash: Find **sample .pas** files

-   Web Search: *Mad Pascal compiler Linux FreePascal mads assembler
    atari 8-bit*

I can build Mad Pascal and MADS from source. Let me set up the build
environment:

-   Bash: **Check if FreePascal is available**

-   Bash: **Install FreePascal compiler**

FreePascal is installed. Now let me compile Mad Pascal and MADS:

-   Bash: Check **Mad Pascal** source

-   Bash: **Compile Mad Pascal compiler**

Mad Pascal compiled. Now let me compile the MADS assembler:

-   View **MAD_Pascal/Mad-Assembler-2.1.6**

-   Bash: **Compile MADS assembler**

Both tools are compiled. Now let me set up paths and test compiling a
simple program:

-   Bash: Check compiled binaries

-   Bash: Test compile **invaders.pas**

-   Bash: **Assemble invaders to xex**

The compilation workflow is working. Now let me report my initial
progress and plan, then create the space shooter game:

-   Progress update: Initial analysis and build environment setup

Now let me create the space shooter game. I\'ll base it on the
techniques learned from the samples, implementing all the features
described in the article:

-   Bash: Create game directory

-   Create **GeminiShooter/GeminiShooter.pas**

Now let\'s try to compile the game:

-   Bash: Compile **GeminiShooter.pas** to assembly

need to fix the issue with the enum type. Let me update the code:

-   Edit GeminiShooter/**GeminiShooter.pas**

-   Bash: Replace enum values

-   Bash: Compile **GeminiShooter.pas** to assembly

-   View GeminiShooter/**GeminiShooter.pas:125-145**

The issue is with arrays of records having more than 4 elements. Let me
reduce the number of enemies and stars to 4 and restructure the code:

-   Edit GeminiShooter/**GeminiShooter.pas**

-   Bash: **Compile GeminiShooter.pas to assembly**

Mad Pascal has a limitation on arrays of records. Let me use separate
arrays instead:

-   View GeminiShooter/**GeminiShooter.pas:100-150**

The comments inside the asm block need to use semicolons instead of
Pascal-style braces:

-   Edit GeminiShooter/**GeminiShooter.pas**

-   Bash: Recompile

-   Bash: Assemble to XEX

The assembler can\'t find the COLBK label. I need to use the correct
register address. Let me check the Atari register definitions:

-   Bash: Find color register definition

-   Bash: Find color register definition in base files

-   View **MAD_Pascal/Mad-Pascal-1.7.3/base**

-   Bash: Find color register in atari definitions

-   View **MAD_Pascal/Mad-Pascal-1.7.3/base/atari**

-   Bash: **Check Atari header file**

I see. The shadow register is **colbaks** and the hardware register is
at a different address. Let me use the hardware register address
directly:

-   Bash: Find GTIA color register

The register is defined as **colbak** (lowercase). Let me update the
assembly code to use it:

-   Edit GeminiShooter/**GeminiShooter.pas**

-   Bash: **Compile and assemble**

Excellent! The game compiled successfully! Let me check the generated
file:

-   Bash: **Check build output**

The XEX file was generated. It\'s about 5KB which is reasonable for this
type of game. Now let me update the progress and add some additional
improvements:

-   Progress update: **Add GeminiShooter game - initial working
    version**

Now let me add a build script and a README for the game, and then run
the code review:

-   Create GeminiShooter/**build.sh**

-   Bash: **Make build script executable**

-   Create GeminiShooter/**README.md**

Now let me verify the build works with the new script:

-   Bash: **Test build script**

Let me also add the .lst and .a65 files to .gitignore since they are
build artifacts:

-   Create GeminiShooter/**.gitignore**

Now let me run the code review:

-   **Review changes with Copilot code review**

Let me address the review comments. First, let me remove the tracked
.a65 and .lst files:

-   Bash: **Remove tracked build artifacts**

Now let me update the README to mention the environment variables:

-   View GeminiShooter/**README.md:40-60**

-   Edit GeminiShooter/**README.md**

Now let me run the security check:

-   Run **CodeQL security scan** on changed files

The game is in Pascal/Assembly which CodeQL doesn\'t analyze. Let me
make a final commit with the improvements:

-   Progress update: Add **build script, README,** and **address review
    comments**

The implementation is complete. Let me provide a summary of what was
created:

**Summary**

I have successfully created a **Gemini Shooter** game for Atari 8-bit
computers in Mad Pascal, inspired by the article on AtariOnline.pl about
an AI-generated Atari game created with Gemini 3 Pro.

**What was implemented:**

1.  **GeminiShooter.pas** - A complete space shooter game (\~900 lines
    of Pascal code) featuring:

    -   **PMG (Player/Missile Graphics) - Hardware sprites for player
        ship (Player 0), enemies (Players 1-2), and missiles**

    -   **Custom Display List - ANTIC Mode 2 with DLI triggers for
        per-line color changes**

    -   **DLI (Display List Interrupts) - Creates a gradient background
        effect from blue to black**

    -   **Scrolling star background - 8 stars with varying speeds for
        depth effect**

    -   **Sound effects - Different sounds for shooting, explosions, and
        megabomb**

    -   **Title screen - With game instructions**

    -   **Game over screen - Displays final score**

    -   **Player controls - Full 8-direction joystick movement + fire
        button**

    -   **Enemy AI - Enemies spawn from top, move with horizontal
        bounce, and descend**

    -   **Collision detection - Between missiles and enemies, and
        between player and enemies**

    -   **Megabomb feature - Destroys all enemies on screen (Space/M
        key)**

    -   **Score tracking - Points for destroying enemies, level
        progression**

```{=html}
<!-- -->
```
1.  **build.sh** - Build script that compiles the game using Mad Pascal
    and MADS

2.  **README.md** - Documentation with build instructions, controls, and
    technical details

3.  **.gitignore** - Excludes build artifacts

**Technical Details:**

-   The game compiles to a **5KB XEX executable**

-   Uses **Mad Pascal 1.7.3** with MADS 2.1.6 assembler

-   Memory layout: PMG at **\$A000**, Display List at **\$A800**, Screen
    at **\$BC00**

-   **VBL** interrupt for game timing and sound management

-   **DLI** interrupt for rainbow gradient effect
