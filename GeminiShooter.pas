{-------------------------------------------------------------------------------
  Game title         : Gemini Shooter
  Author             : AI-Generated (Mad Pascal port inspired by Gemini 3 Pro)
  Platform           : Atari 8-bit XL/XE
  
  Description:
  A space shooter game featuring:
  - PMG (Player/Missile Graphics) for player ship and enemies
  - Custom Display List with mixed text/graphics modes
  - DLI (Display List Interrupts) for colorful effects
  - Scrolling star background
  - Sound effects for shooting and explosions
  - Title screen and Game Over screen
  - Megabomb special weapon
  - Score tracking
  
  Based on techniques from "De Re Atari", "Altirra Hardware Manual",
  and "Poradnik programisty Atari" by Wojciech Zientara.
-------------------------------------------------------------------------------}

program GeminiShooter;

{$librarypath '../blibs/'}

uses atari, crt, b_pmg, b_dl, joystick, sysutils;

const
  { Screen dimensions }
  SCREEN_WIDTH = 40;
  SCREEN_HEIGHT = 24;
  
  { PMG Memory locations }
  PMG_BASE = $A000;
  
  { Player ship sprite (8 bytes, one-line resolution) }
  PLAYER_SHIP: array [0..7] of byte = (
    %00011000,   {    **    }
    %00111100,   {   ****   }
    %01111110,   {  ******  }
    %11111111,   { ******** }
    %11011011,   { ** ** ** }
    %01111110,   {  ******  }
    %00100100,   {   *  *   }
    %01100110    {  **  **  }
  );
  
  { Enemy ship sprite }
  ENEMY_SHIP: array [0..7] of byte = (
    %10000001,   { *      * }
    %11000011,   { **    ** }
    %01100110,   {  **  **  }
    %00111100,   {   ****   }
    %01111110,   {  ******  }
    %11111111,   { ******** }
    %01011010,   {  * ** *  }
    %00100100    {   *  *   }
  );
  
  { Missile sprite (thin line) }
  MISSILE_SHAPE: byte = %11000000;
  
  { Enemy bullet sprite }  
  ENEMY_BULLET: byte = %11000000;
  
  { Explosion sprite }
  EXPLOSION: array [0..7] of byte = (
    %10010010,   { *  *  *  }
    %01001001,   {  *  *  * }
    %00111100,   {   ****   }
    %11111111,   { ******** }
    %11111111,   { ******** }
    %00111100,   {   ****   }
    %01001001,   {  *  *  * }
    %10010010    { *  *  *  }
  );
  
  { Game constants }
  MAX_ENEMIES = 3;
  MAX_STARS = 8;
  PLAYER_START_X = 128;
  PLAYER_Y = 180;
  ENEMY_SPAWN_Y = 40;
  
  { Colors }
  COLOR_PLAYER = $0E;       { White }
  COLOR_ENEMY1 = $44;       { Red }
  COLOR_ENEMY2 = $C6;       { Green }
  COLOR_MISSILE = $1E;      { Yellow }
  COLOR_STAR = $0A;         { Gray }
  COLOR_BACKGROUND = $00;   { Black }
  
  { Sound frequencies }
  SND_SHOOT = 100;
  SND_EXPLOSION = 200;
  SND_MEGABOMB = 50;

const
  { Enemy states }
  ES_NONE = 0;
  ES_ALIVE = 1;
  ES_EXPLODING = 2;

var
  { Game state }
  gameRunning: boolean;
  gameOver: boolean;
  score: word;
  lives: byte;
  megaBombs: byte;
  level: byte;
  
  { Player state }
  playerX: byte;
  playerY: byte;
  playerMissileActive: boolean;
  playerMissileX, playerMissileY: byte;
  
  { Enemies - using separate arrays instead of array of records }
  enemyX: array [0..MAX_ENEMIES-1] of byte;
  enemyY: array [0..MAX_ENEMIES-1] of byte;
  enemyDX: array [0..MAX_ENEMIES-1] of shortint;
  enemyState: array [0..MAX_ENEMIES-1] of byte;
  enemyExplodeTimer: array [0..MAX_ENEMIES-1] of byte;
  enemySpawnTimer: byte;
  
  { Stars for scrolling background - using separate arrays }
  starX: array [0..MAX_STARS-1] of byte;
  starY: array [0..MAX_STARS-1] of byte;
  starSpeed: array [0..MAX_STARS-1] of byte;
  
  { Display list memory }
  displayList: array [0..63] of byte absolute $A800;
  screenMem: word;
  
  { Timing }
  frameCounter: byte;
  soundTimer: byte;
  
  { DLI color table for rainbow effect }
  dliColors: array [0..23] of byte;
  dliLine: byte;
  
  { Input state }
  lastTrigger: byte;
  
  { Old interrupt vectors }
  oldDLI, oldVBL: pointer;

{ ============================================================================ }
{ Helper procedure to print a string at a screen address }
{ ============================================================================ }
procedure PrintStr(addr: word; s: PChar; len: byte);
var
  i: byte;
begin
  for i := 0 to len - 1 do
    Poke(addr + i, byte(s[i+1]));
end;

{ ============================================================================ }
{ Display List Interrupt - Changes colors per scanline for visual effect }
{ ============================================================================ }
procedure DLIHandler; interrupt; assembler;
asm
  pha
  txa
  pha
  
  ; Get current DLI line counter
  ldx dliLine
  
  ; Load color for this line
  lda dliColors,x
  sta wsync
  sta colbak
  
  ; Advance to next line
  inx
  cpx #24
  bcc @noReset
  ldx #0
@noReset:
  stx dliLine
  
  pla
  tax
  pla
  rti
end;

{ ============================================================================ }
{ Vertical Blank Interrupt - Main game timing }
{ ============================================================================ }
procedure VBLHandler; interrupt;
begin
  { Reset DLI line counter }
  dliLine := 0;
  
  { Increment frame counter }
  Inc(frameCounter);
  
  { Decrease sound timer }
  if soundTimer > 0 then
    Dec(soundTimer)
  else
    Sound(0, 0, 0, 0);
  
  asm
    jmp xitvbv
  end;
end;

{ ============================================================================ }
{ Initialize DLI color table for space background effect }
{ ============================================================================ }
procedure InitDLIColors;
var
  i: byte;
begin
  { Create gradient from dark blue to black }
  for i := 0 to 11 do
    dliColors[i] := $90 - (i * 8);  { Blue gradient }
  for i := 12 to 23 do
    dliColors[i] := $00;            { Black }
end;

{ ============================================================================ }
{ Initialize Display List for the game }
{ ============================================================================ }
procedure InitDisplayList;
var
  i: byte;
begin
  screenMem := $BC00;
  
  DL_Init(word(@displayList));
  
  { 8 blank lines at top }
  DL_Push(DL_BLANK8);
  DL_Push(DL_BLANK8);
  DL_Push(DL_BLANK8);
  
  { First line with LMS - Mode 2 (40x24 text) with DLI }
  DL_Push(DL_MODE_40x24T2 or DL_LMS or DL_DLI, screenMem);
  
  { 23 more lines of text mode with DLI on each }
  for i := 1 to 23 do
    DL_Push(DL_MODE_40x24T2 or DL_DLI);
  
  { Jump back to beginning }
  DL_Push(DL_JVB, word(@displayList));
  
  DL_Start;
end;

{ ============================================================================ }
{ Initialize Player/Missile Graphics }
{ ============================================================================ }
procedure InitPMG;
begin
  PMG_Init(Hi(PMG_BASE), PMG_sdmctl_default or PMG_sdmctl_oneline, PMG_gractl_default);
  PMG_Clear;
  
  { Set player colors }
  PMG_pcolr0_S := COLOR_PLAYER;    { Player ship }
  PMG_pcolr1_S := COLOR_ENEMY1;    { Enemy 1 }
  PMG_pcolr2_S := COLOR_ENEMY2;    { Enemy 2 }
  PMG_pcolr3_S := COLOR_MISSILE;   { Missiles }
  
  { Set priority - players over playfield }
  PMG_gprior_S := %00000001;
end;

{ ============================================================================ }
{ Draw player ship at current position }
{ ============================================================================ }
procedure DrawPlayer;
var
  pmgAddr: word;
begin
  pmgAddr := PMG_BASE + $400 + playerY;
  
  { Clear previous position }
  FillChar(pointer(pmgAddr - 2), 12, 0);
  
  { Draw player ship }
  Move(PLAYER_SHIP, pointer(pmgAddr), 8);
  
  { Set horizontal position }
  PMG_hpos0 := playerX;
end;

{ ============================================================================ }
{ Draw enemy at specified player number }
{ ============================================================================ }
procedure DrawEnemy(enemyNum: byte);
var
  pmgAddr: word;
  pmNum: byte;
begin
  if enemyNum >= MAX_ENEMIES then Exit;
  
  pmNum := (enemyNum mod 2) + 1;  { Use players 1 and 2 }
  pmgAddr := PMG_BASE + $400 + (pmNum * $100) + enemyY[enemyNum];
  
  case enemyState[enemyNum] of
    ES_ALIVE: begin
      { Clear and draw enemy }
      FillChar(pointer(pmgAddr - 2), 12, 0);
      Move(ENEMY_SHIP, pointer(pmgAddr), 8);
      PMG_hpos[pmNum] := enemyX[enemyNum];
    end;
    ES_EXPLODING: begin
      { Draw explosion }
      FillChar(pointer(pmgAddr - 2), 12, 0);
      Move(EXPLOSION, pointer(pmgAddr), 8);
      PMG_hpos[pmNum] := enemyX[enemyNum];
    end;
    ES_NONE: begin
      { Clear enemy }
      FillChar(pointer(pmgAddr - 2), 12, 0);
      PMG_hpos[pmNum] := 0;
    end;
  end;
end;

{ ============================================================================ }
{ Draw player missile }
{ ============================================================================ }
procedure DrawPlayerMissile;
var
  pmgAddr: word;
begin
  { Use missile 0 }
  pmgAddr := PMG_BASE + $300 + playerMissileY;
  
  if playerMissileActive then begin
    { Clear and draw missile }
    Poke(pmgAddr - 1, 0);
    Poke(pmgAddr, MISSILE_SHAPE);
    Poke(pmgAddr + 1, MISSILE_SHAPE);
    PMG_hposm0 := playerMissileX;
  end else begin
    FillChar(pointer(pmgAddr - 2), 4, 0);
    PMG_hposm0 := 0;
  end;
end;

{ ============================================================================ }
{ Initialize stars for scrolling background }
{ ============================================================================ }
procedure InitStars;
var
  i: byte;
begin
  for i := 0 to MAX_STARS - 1 do begin
    starX[i] := Random(SCREEN_WIDTH);
    starY[i] := Random(SCREEN_HEIGHT);
    starSpeed[i] := Random(3) + 1;
  end;
end;

{ ============================================================================ }
{ Update and draw scrolling stars }
{ ============================================================================ }
procedure UpdateStars;
var
  i: byte;
  addr: word;
  oldAddr: word;
begin
  for i := 0 to MAX_STARS - 1 do begin
    { Clear old star position }
    oldAddr := screenMem + (starY[i] * SCREEN_WIDTH) + starX[i];
    Poke(oldAddr, 0);
    
    { Move star down }
    Inc(starY[i], starSpeed[i]);
    
    { Wrap around at bottom }
    if starY[i] >= SCREEN_HEIGHT then begin
      starY[i] := 0;
      starX[i] := Random(SCREEN_WIDTH);
      starSpeed[i] := Random(3) + 1;
    end;
    
    { Draw new star position (use '.' character) }
    addr := screenMem + (starY[i] * SCREEN_WIDTH) + starX[i];
    Poke(addr, 14);  { Period character }
  end;
end;

{ ============================================================================ }
{ Play sound effect }
{ ============================================================================ }
procedure PlaySound(freq, dist, vol, duration: byte);
begin
  Sound(0, freq, dist, vol);
  soundTimer := duration;
end;

{ ============================================================================ }
{ Initialize game state }
{ ============================================================================ }
procedure InitGame;
var
  i: byte;
begin
  gameRunning := true;
  gameOver := false;
  score := 0;
  lives := 3;
  megaBombs := 3;
  level := 1;
  
  playerX := PLAYER_START_X;
  playerY := PLAYER_Y;
  playerMissileActive := false;
  
  { Clear enemies }
  for i := 0 to MAX_ENEMIES - 1 do begin
    enemyState[i] := ES_NONE;
    enemyX[i] := 0;
    enemyY[i] := 0;
  end;
  
  enemySpawnTimer := 50;
  frameCounter := 0;
  lastTrigger := 1;
  
  { Clear screen }
  FillChar(pointer(screenMem), SCREEN_WIDTH * SCREEN_HEIGHT, 0);
  
  { Initialize stars }
  InitStars;
  
  { Draw player }
  DrawPlayer;
end;

{ ============================================================================ }
{ Spawn a new enemy }
{ ============================================================================ }
procedure SpawnEnemy;
var
  i: byte;
begin
  for i := 0 to MAX_ENEMIES - 1 do begin
    if enemyState[i] = ES_NONE then begin
      enemyX[i] := Random(160) + 48;
      enemyY[i] := ENEMY_SPAWN_Y;
      enemyDX[i] := Random(5) - 2;
      if enemyDX[i] = 0 then enemyDX[i] := 1;
      enemyState[i] := ES_ALIVE;
      enemyExplodeTimer[i] := 0;
      Exit;
    end;
  end;
end;

{ ============================================================================ }
{ Update enemies }
{ ============================================================================ }
procedure UpdateEnemies;
var
  i: byte;
begin
  for i := 0 to MAX_ENEMIES - 1 do begin
    case enemyState[i] of
      ES_ALIVE: begin
        { Move enemy }
        enemyX[i] := byte(shortint(enemyX[i]) + enemyDX[i]);
        Inc(enemyY[i], 1 + (level div 3));
        
        { Bounce off screen edges }
        if enemyX[i] < 48 then begin
          enemyX[i] := 48;
          enemyDX[i] := -enemyDX[i];
        end;
        if enemyX[i] > 200 then begin
          enemyX[i] := 200;
          enemyDX[i] := -enemyDX[i];
        end;
        
        { Remove if off screen }
        if enemyY[i] > 220 then begin
          enemyState[i] := ES_NONE;
          { Player loses a life if enemy escapes }
          if lives > 0 then Dec(lives);
        end;
        
        DrawEnemy(i);
      end;
      
      ES_EXPLODING: begin
        Inc(enemyExplodeTimer[i]);
        if enemyExplodeTimer[i] > 10 then begin
          enemyState[i] := ES_NONE;
          { Clear the explosion }
          DrawEnemy(i);
        end else
          DrawEnemy(i);
      end;
    end;
  end;
end;

{ ============================================================================ }
{ Check collision between player missile and enemies }
{ ============================================================================ }
procedure CheckMissileCollision;
var
  i: byte;
  dx, dy: shortint;
begin
  if not playerMissileActive then Exit;
  
  for i := 0 to MAX_ENEMIES - 1 do begin
    if enemyState[i] = ES_ALIVE then begin
      dx := shortint(playerMissileX) - shortint(enemyX[i]);
      dy := shortint(playerMissileY) - shortint(enemyY[i]);
      
      { Simple bounding box collision }
      if (Abs(dx) < 12) and (Abs(dy) < 12) then begin
        { Hit! }
        enemyState[i] := ES_EXPLODING;
        enemyExplodeTimer[i] := 0;
        playerMissileActive := false;
        
        { Add score }
        Inc(score, 10 * level);
        
        { Play explosion sound }
        PlaySound(SND_EXPLOSION, 8, 10, 10);
        
        Exit;
      end;
    end;
  end;
end;

{ ============================================================================ }
{ Check collision between player and enemies }
{ ============================================================================ }
procedure CheckPlayerCollision;
var
  i: byte;
  dx, dy: shortint;
begin
  for i := 0 to MAX_ENEMIES - 1 do begin
    if enemyState[i] = ES_ALIVE then begin
      dx := shortint(playerX) - shortint(enemyX[i]);
      dy := shortint(playerY) - shortint(enemyY[i]);
      
      { Simple bounding box collision }
      if (Abs(dx) < 10) and (Abs(dy) < 10) then begin
        { Player hit! }
        enemyState[i] := ES_EXPLODING;
        enemyExplodeTimer[i] := 0;
        
        if lives > 0 then Dec(lives);
        
        { Play explosion sound }
        PlaySound(SND_EXPLOSION, 10, 15, 15);
        
        Exit;
      end;
    end;
  end;
end;

{ ============================================================================ }
{ Megabomb - destroys all enemies on screen }
{ ============================================================================ }
procedure ActivateMegabomb;
var
  i: byte;
begin
  if megaBombs = 0 then Exit;
  
  Dec(megaBombs);
  
  { Destroy all enemies }
  for i := 0 to MAX_ENEMIES - 1 do begin
    if enemyState[i] = ES_ALIVE then begin
      enemyState[i] := ES_EXPLODING;
      enemyExplodeTimer[i] := 0;
      Inc(score, 10 * level);
    end;
  end;
  
  { Flash screen effect }
  Color2 := $0F;
  
  { Play megabomb sound }
  PlaySound(SND_MEGABOMB, 12, 15, 20);
end;

{ ============================================================================ }
{ Handle player input }
{ ============================================================================ }
procedure HandleInput;
var
  stick: byte;
  trigger: byte;
  ch: char;
begin
  stick := STICK0;
  trigger := STRIG0;
  
  { Joystick movement }
  if (stick and %0100) = 0 then begin  { Right }
    if playerX <= 200 then Dec(playerX, 2);
    if playerX < 48 then playerX := 200;
  end;
  if (stick and %1000) = 0 then begin  { Left }
    if playerX >= 48 then Inc(playerX, 2);
    if playerX > 200 then playerX := 48;
  end;
  if (stick and %0001) = 0 then begin  { Up }
    if playerY > 100 then Dec(playerY, 2);
  end;
  if (stick and %0010) = 0 then begin  { Down }
    if playerY < 210 then Inc(playerY, 2);
  end;
  
  { Fire button - shoot missile }
  if (trigger = 0) and (lastTrigger = 1) then begin
    if not playerMissileActive then begin
      playerMissileActive := true;
      playerMissileX := playerX;
      playerMissileY := playerY - 8;
      PlaySound(SND_SHOOT, 10, 8, 5);
    end;
  end;
  lastTrigger := trigger;
  
  { Keyboard - Megabomb with Space or M key }
  if Keypressed then begin
    ch := ReadKey;
    if (ch = ' ') or (ch = 'm') or (ch = 'M') then
      ActivateMegabomb;
  end;
end;

{ ============================================================================ }
{ Update player missile }
{ ============================================================================ }
procedure UpdatePlayerMissile;
begin
  if playerMissileActive then begin
    if playerMissileY > 8 then begin
      Dec(playerMissileY, 4);
      DrawPlayerMissile;
    end else begin
      playerMissileActive := false;
      DrawPlayerMissile;
    end;
  end;
end;

{ ============================================================================ }
{ Draw HUD (score, lives, bombs) }
{ ============================================================================ }
procedure DrawHUD;
var
  scoreStr: string[10];
  addr: word;
  i: byte;
begin
  addr := screenMem;
  
  { Score }
  Str(score, scoreStr);
  PrintStr(addr, 'SCORE:'~, 6);
  for i := 1 to Length(scoreStr) do
    Poke(addr + 5 + i, byte(scoreStr[i]) - $20);
  
  { Lives }
  addr := screenMem + 20;
  PrintStr(addr, 'LIVES:'~, 6);
  Poke(addr + 6, $10 + lives
  ) ;
  
  { Megabombs }
  addr := screenMem + 30;
  PrintStr(addr, 'BOMBS:'~, 6);
  Poke(addr + 6, $10 + megaBombs);
end;

{ ============================================================================ }
{ Display title screen }
{ ============================================================================ }
procedure TitleScreen;
var
  addr: word;
begin
  { Clear screen }
  FillChar(pointer(screenMem), SCREEN_WIDTH * SCREEN_HEIGHT, 0);
  
  { Title }
  addr := screenMem + (5 * SCREEN_WIDTH) + 10;
  PrintStr(addr, 'GEMINI SHOOTER'~, 14);
  
  { Subtitle }
  addr := screenMem + (7 * SCREEN_WIDTH) + 6;
  PrintStr(addr, 'AI-GENERATED ATARI GAME'~, 23);
  
  { Instructions }
  addr := screenMem + (10 * SCREEN_WIDTH) + 5;
  PrintStr(addr, 'JOYSTICK: MOVE SHIP'~, 19);
  
  addr := screenMem + (12 * SCREEN_WIDTH) + 5;
  PrintStr(addr, 'BUTTON: FIRE MISSILE'~, 20);
  
  addr := screenMem + (14 * SCREEN_WIDTH) + 5;
  PrintStr(addr, 'SPACE/M: MEGABOMB'~, 17);
  
  { Press Fire }
  addr := screenMem + (18 * SCREEN_WIDTH) + 8;
  PrintStr(addr, 'PRESS FIRE TO START'~, 19);
  
  { Credits }
  addr := screenMem + (22 * SCREEN_WIDTH) + 3;
  PrintStr(addr, 'INSPIRED BY GEMINI 3 PRO'~, 24);
  
  { Wait for fire button }
  repeat
    Pause;
  until STRIG0 = 0;
  
  { Wait for release }
  repeat
    Pause;
  until STRIG0 = 1;
end;

{ ============================================================================ }
{ Display game over screen }
{ ============================================================================ }
procedure GameOverScreen;
var
  addr: word;
  scoreStr: string[10];
  i: byte;
begin
  { Clear screen }
  FillChar(pointer(screenMem), SCREEN_WIDTH * SCREEN_HEIGHT, 0);
  
  { Game Over }
  addr := screenMem + (8 * SCREEN_WIDTH) + 14;
  PrintStr(addr, 'GAME OVER'~, 9);
  
  { Final Score }
  addr := screenMem + (12 * SCREEN_WIDTH) + 10;
  Str(score, scoreStr);
  PrintStr(addr, 'FINAL SCORE: '~, 13);
  for i := 1 to Length(scoreStr) do
    Poke(addr + 12 + i, byte(scoreStr[i]) - $20);
  
  { Press Fire }
  addr := screenMem + (18 * SCREEN_WIDTH) + 8;
  PrintStr(addr, 'PRESS FIRE TO PLAY'~, 18);
  
  { Play game over sound }
  Sound(0, 200, 10, 8);
  Delay(100);
  Sound(0, 150, 10, 8);
  Delay(100);
  Sound(0, 100, 10, 8);
  Delay(100);
  Sound(0, 0, 0, 0);
  
  { Wait for fire button }
  repeat
    Pause;
  until STRIG0 = 0;
  
  { Wait for release }
  repeat
    Pause;
  until STRIG0 = 1;
end;

{ ============================================================================ }
{ Main game loop }
{ ============================================================================ }
procedure GameLoop;
begin
  while gameRunning do begin
    { Handle player input }
    HandleInput;
    
    { Update player }
    DrawPlayer;
    
    { Update missile }
    UpdatePlayerMissile;
    
    { Update enemies }
    UpdateEnemies;
    
    { Check collisions }
    CheckMissileCollision;
    CheckPlayerCollision;
    
    { Spawn new enemies periodically }
    if enemySpawnTimer > 0 then
      Dec(enemySpawnTimer)
    else begin
      SpawnEnemy;
      enemySpawnTimer := 60 - (level * 5);
      if enemySpawnTimer < 20 then enemySpawnTimer := 20;
    end;
    
    { Update stars (every 2 frames for performance) }
    if (frameCounter mod 2) = 0 then
      UpdateStars;
    
    { Restore background color after megabomb flash }
    if Color2 <> COLOR_BACKGROUND then
      Color2 := COLOR_BACKGROUND;
    
    { Draw HUD }
    DrawHUD;
    
    { Check game over condition }
    if lives = 0 then begin
      gameOver := true;
      gameRunning := false;
    end;
    
    { Level progression based on score }
    level := 1 + (score div 100);
    if level > 10 then level := 10;
    
    { Wait for next frame }
    Pause;
  end;
end;

{ ============================================================================ }
{ Main program }
{ ============================================================================ }
begin
  { Initialize system }
  Randomize;
  
  { Disable cursor }
  Poke(752, 1);
  
  { Set colors }
  Color0 := $0E;   { White text }
  Color1 := $46;   { Red }
  Color2 := COLOR_BACKGROUND;
  Color3 := $96;   { Blue }
  Color4 := $00;   { Black border }
  
  { Initialize DLI colors }
  InitDLIColors;
  
  { Initialize custom display list }
  InitDisplayList;
  
  { Initialize PMG }
  InitPMG;
  
  { Save old interrupt vectors }
  GetIntVec(iDLI, oldDLI);
  GetIntVec(iVBL, oldVBL);
  
  { Install our interrupt handlers }
  SetIntVec(iDLI, @DLIHandler);
  SetIntVec(iVBL, @VBLHandler);
  
  { Enable DLI }
  Poke($D40E, $C0);
  
  { Main game loop }
  repeat
    TitleScreen;
    InitGame;
    GameLoop;
    
    if gameOver then
      GameOverScreen;
  until false;
  
  { Restore interrupts (never reached but good practice) }
  SetIntVec(iVBL, oldVBL);
  SetIntVec(iDLI, oldDLI);
  
  { Disable DLI }
  Poke($D40E, $40);
  
  { Clean up PMG }
  PMG_Disable;
end.
