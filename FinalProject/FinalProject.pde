import ddf.minim.*;

import java.util.*;
import java.awt.*;
import java.io.*;

Game game;
Profile profile;  // currently loaded profile

// Database stuff
DatabaseLoader dl;
ShipXMLEntries g_ships;
ProjectileXMLEntries g_projectiles;
WeaponXMLEntries g_weapons;

int game_state;
int previous;

// ---------------------
// CONSTANTS
ArrayList sprites = new ArrayList();
ArrayList<MenuButton> menuButtons = new ArrayList<MenuButton>();
ArrayList<MenuButton> loadoutButtons = new ArrayList<MenuButton>();
ArrayList<MenuButton> optionButtons = new ArrayList<MenuButton>();
boolean drawBoxes;
PFont myFont;
// ---------------------

void setup()
{
  size(800, 600);
  frameRate(60);
  frame.setResizable(true);
  InitApplication();
  InitBackground();
  InitMenu();
  InitSounds();
}

// Updates the physics on a fixed time scale (60 updates per second!)
void update()
{
  if(isGameActive())
  {
    game.update();
  }
}

// Actually render the game.
void render(float norm)
{
  drawBackground();
  
  switch(game_state)
  {
    case GAME_STATE_RUNNING:
      game.draw(norm);
      break;
    case GAME_STATE_MAIN_MENU:
      displayMenu();
      break;
    case GAME_STATE_LOADOUT:
      displayLoadout();
      break;
    case GAME_STATE_OPTION:
      displayOptions();
      break;
    default:
      println("render(): ERROR! INVALID GAME STATE!");
      break;
  }
}

// Our main game loop starts in draw()
void draw()
{ 
  float lag = 0.0; 
  int current = millis();
  int elapsed = current - previous;
  previous = current;
  lag += elapsed;

  while(lag >= MS_PER_UPDATE)
  {
    update();
    lag -= MS_PER_UPDATE;
  }
  
  float norm = lag / (float)MS_PER_UPDATE;  // normalize the lag value so that it will be between 0.0 and 1.0
  render(norm);
}

// Load important stuff at application launch.
void InitApplication()
{
  g_ships = new ShipXMLEntries();
  g_projectiles = new ProjectileXMLEntries();
  g_weapons = new WeaponXMLEntries();
  
  dl = new DatabaseLoader();
  dl.LoadGameData();               // load the database!
  
  // THIS IS REALLY BAD. WHAT I WANT TO DO IS ACTUALLY LOAD THE DATA FOR THE PROFILE FROM A SERIALIZED FILE.
  // UNFORTUNATELY AN ERROR IS PREVENTING THAT FROM HAPPENING. SO IN THIS CASE, THE ONLY THING I AM DOING IS HARD-CODING THE VALUES.
  // THIS IS WRONG. WRONG WRONG WRONG WRROOOONNNGGGGG AND IT COMPLETELY INVALIDATES ANYTHING I WANT TO DO.
  // WILL FIX SOMETIME. BUT NOW LET'S JUST GET A PROTOTYPE WORKING.
  profile = new Profile(0,0,0,3);  // level, xp, primaryType (XML), secondaryType (XML)
  //LoadProfileData(profile);
  
  game = new Game();
  SetGameState(GAME_STATE_MAIN_MENU);
  previous = millis();
}

void InitBackground()
{
  sprites.add( new Sprite(Custom_LoadImage("stars1.png"), 40, 48, 1, 1));
  sprites.add( new Sprite(Custom_LoadImage("stars2.png"), 440, 48, 1, 1));
  sprites.add( new Sprite(Custom_LoadImage("stars2.png"), 920, 48, 1, 1));
   
  sprites.add( new Sprite(Custom_LoadImage("stars1.png"), 0, 40, 1, 2));
  sprites.add( new Sprite(Custom_LoadImage("stars2.png"), 400, 40, 1, 2));
  sprites.add( new Sprite(Custom_LoadImage("stars2.png"), 960, 40, 1, 2));
    
  sprites.add( new Sprite(Custom_LoadImage("stars1.png"), 200, 40, 1, 3 ));
  sprites.add( new Sprite(Custom_LoadImage("stars1.png"), 360, 40, 1, 3 ));
  sprites.add( new Sprite(Custom_LoadImage("stars1.png"), 1000, 40, 1, 3 ));
}

void InitMenu()
{
  int offsetX = width/2  - 100;
  int offsetY = height/2;
  
  menuButtons.add( new MenuButton("Start Game", new PVector(offsetX, offsetY), 32, color(255), color(255, 0, 0))     );
  menuButtons.add( new MenuButton("Loadout", new PVector(offsetX, offsetY + 100), 32, color(255), color(255, 0, 0))  );
  menuButtons.add( new MenuButton("Options", new PVector(offsetX, offsetY + 200), 32, color(255), color(255, 0, 0))  );
  
  loadoutButtons.add( new MenuButton("Primary Weapon (NYI)", new PVector(offsetX, offsetY), 32, color(255), color(255, 0, 0))         );
  loadoutButtons.add( new MenuButton("Secondary Weapon (NYI)", new PVector(offsetX, offsetY + 45), 32, color(255), color(255, 0, 0))  );
  loadoutButtons.add( new MenuButton("Offense Module (NYI)", new PVector(offsetX, offsetY + 90), 32, color(255), color(255, 0, 0))    );
  loadoutButtons.add( new MenuButton("Defense Module (NYI)", new PVector(offsetX, offsetY + 135), 32, color(255), color(255, 0, 0))   );
  loadoutButtons.add( new MenuButton("Utility Module (NYI)", new PVector(offsetX, offsetY + 180), 32, color(255), color(255, 0, 0))   );
  loadoutButtons.add( new MenuButton("Return to Main Menu", new PVector(offsetX, offsetY + 220), 32, color(255), color(255, 0, 0))             );
  
  MenuButton temp = new MenuButton("Resolution", new PVector(offsetX, offsetY), 32, color(255), color(255, 0, 0));
  optionButtons.add(temp);
  temp.setDisable(true);
  optionButtons.add( new MenuButton("800x600", new PVector(offsetX + 120, offsetY + 16), 16, color(255), color(255, 0, 0))   );
  optionButtons.add( new MenuButton("1024x768", new PVector(offsetX + 180, offsetY + 16), 16, color(255), color(255, 0, 0))   );
  optionButtons.add( new MenuButton("1400x1050", new PVector(offsetX + 240, offsetY + 16), 16, color(255), color(255, 0, 0))   );
  optionButtons.add( new MenuButton("Return to Main Menu", new PVector(offsetX, offsetY + 220), 32, color(255), color(255, 0, 0))             );
  
  drawBoxes = false;
}

// Start a game
void StartGame()
{
  if(isGameActive()) return;
  
  SetGameState(GAME_STATE_RUNNING);
  game.Init();
  
  UpdateMusic();
}

// End a game
void ExitGame()
{
  SetGameState(GAME_STATE_MAIN_MENU);
  game.Uninit();
  
  UpdateMusic();
}

// Are we currently playing the game?
boolean isGameActive()
{
  return (game_state == GAME_STATE_RUNNING);
}

void SetGameState(int state)
{
  game_state = state;
}

// Handles all input.
void handleInput(int k, boolean bPressed)
{
  if(isGameActive())
  {
    game.handleInput(keyCode, bPressed);
  }
}

//draw background
void drawBackground()
{
  ArrayList newSpr = new ArrayList();
    
  background(0);
  for( Iterator i = sprites.iterator(); i.hasNext(); )
  {
    Sprite spr = (Sprite)i.next();
    spr.draw();
    spr.moveBy( -5 * spr.layer, 0);
  
    if(spr.isVisible())
    {
      newSpr.add( spr );
    }
    else
    {
      spr = new Sprite( spr.img, 1280, spr.y, spr.s, spr.layer );
      newSpr.add( spr );
    }  
  } 
  sprites = newSpr;   
}

// Handle input
void keyPressed() { handleInput(keyCode, true); }
void keyReleased() { handleInput(keyCode, false); }

void mousePressed()
{
  int n_width = width;
  int n_height = height;
  
  switch(game_state)
  {
    case GAME_STATE_MAIN_MENU:
      if (menuButtons.get(0).containsMouse())
      {
        StartGame();
      }
      if (menuButtons.get(1).containsMouse())
      {
        SetGameState(GAME_STATE_LOADOUT);
      }
      if (menuButtons.get(menuButtons.size()-1).containsMouse())
      {
        SetGameState(GAME_STATE_OPTION);
      }
      break;
    case GAME_STATE_LOADOUT:
      if (loadoutButtons.get(0).containsMouse())
      {
        //text("test", 10, 10);
      }
      if (loadoutButtons.get(1).containsMouse())
      {
        //draw secondary drop list
      }
      if (loadoutButtons.get(2).containsMouse())
      {
        //drop 
      }
      if (loadoutButtons.get(3).containsMouse())
      {
        //drop 
      }
      if (loadoutButtons.get(4).containsMouse())
      {
        //drop 
      }
      if (loadoutButtons.get(loadoutButtons.size()-1).containsMouse())
      {
        SetGameState(GAME_STATE_MAIN_MENU);
      }
      break;
    case GAME_STATE_OPTION:
      MenuButton button800x600 = optionButtons.get(1);
      MenuButton button1024x768 = optionButtons.get(2);
      MenuButton button1400x1050 = optionButtons.get(3);
      // 800 x 600
      if (button800x600.containsMouse())
      {
        n_width = 800;
        n_height = 600;
      }
      if (button1024x768.containsMouse())
      {
        n_width = 1024;
        n_height = 768;
      }
      if (button1400x1050.containsMouse())
      {
        n_width = 1400;
        n_height = 1050;
      }
      if (optionButtons.get(optionButtons.size()-1).containsMouse())
      {
        SetGameState(GAME_STATE_MAIN_MENU);
      }
      break;
    default:
      break;
  }
  
  if(n_width != width && n_height != height)
  {
    frame.setSize(n_width + 16, n_height + 38);
  }
}

////////////////////////////////////////
// Display Menu Functions
void displayMenu()
{
  myFont = Custom_LoadFont("PressStart2P-Regular.vlw");
  text("It's A Space Shooter!", width/2 - 100, height/4);
  textSize(16);
  text("Use arrow keys or WASD to move", 40, height-40);
  text("Press the spacebar to shoot", 40, height-20);
  textFont(myFont);
  fill(0,0,0);
  
  for (int i = 0; i < menuButtons.size(); i++)
  {
    menuButtons.get(i).draw(drawBoxes);
  }
}

void displayLoadout()
{
  myFont = Custom_LoadFont("PressStart2P-Regular.vlw");
  text("Customization", width/2 - 100, height/4);
  textFont(myFont);
  fill(0,0,0);
  
  for (int i = 0; i < loadoutButtons.size(); i++)
  {
    loadoutButtons.get(i).draw(drawBoxes);
  }
}

void displayOptions()
{
  myFont = Custom_LoadFont("PressStart2P-Regular.vlw");
  text("Options", width/2 - 100, height/4);
  textFont(myFont);
  fill(0,0,0);

  for (int i = 0; i < optionButtons.size(); i++)
  {
    optionButtons.get(i).draw(drawBoxes);
  }
  
  MenuButton button800x600 = optionButtons.get(1);
  MenuButton button1024x768 = optionButtons.get(2);
  MenuButton button1400x1050 = optionButtons.get(3);
  
  button800x600.setHighlight(false);
  button1024x768.setHighlight(false);
  button1400x1050.setHighlight(false);
  
  println(width, height);
  
  if(width == 800 && height == 600)
    button800x600.setHighlight(true);
  else if(width == 1024 && height == 768)
    button1024x768.setHighlight(true);
  else if(width == 1400 && height == 1050)
    button1400x1050.setHighlight(true);
}
////////////////////////////////////////

// Ships
ShipEntry GetGameShipEntry(int index) { return GetGameShipEntries().get(index); }          // Get a specific entry
ArrayList<ShipEntry> GetGameShipEntries() { return GetGameShips().GetEntries(); }          // Get the ArrayList that stores the entries
ShipXMLEntries GetGameShips() { return g_ships; };                                         // Get the ship objects

// Projectiles
ProjectileEntry GetGameProjectileEntry(int index) { return GetGameProjectileEntries().get(index); }
ArrayList<ProjectileEntry> GetGameProjectileEntries() { return GetGameProjectiles().GetEntries(); }
ProjectileXMLEntries GetGameProjectiles() { return g_projectiles; };

// Weapons
WeaponEntry GetGameWeaponEntry(int index) { return GetGameWeaponEntries().get(index); }
ArrayList<WeaponEntry> GetGameWeaponEntries() { return GetGameWeapons().GetEntries(); }
WeaponXMLEntries GetGameWeapons() { return g_weapons; };

class MenuButton
{
  PVector pos;
  color textColor, hoverColor;
  float size, tWidth;
  String text;
  boolean disable;
  boolean highlight;
 
  MenuButton(String text, PVector pos, float size, color textColor, color hoverColor)
  {
    this.pos = pos;
    this.textColor = textColor;
    this.hoverColor = hoverColor;
    this.size = size;
    this.text = text;
    textSize(size);
    tWidth = textWidth(text);
    disable = false;
    highlight = false;
  }
 
  void draw(boolean on)
  {
    textSize(size);
    if(isHighlight())
    {
      fill(hoverColor);
    }
    else
    {
      if(!isDisable() && containsMouse())
        fill(hoverColor);
      else
        fill(textColor);
    }
    
    text(text, pos.x, pos.y + size);
    if (on)
      rect(pos.x, pos.y, tWidth, size);
    fill(textColor);
  }
  
  void setDisable(boolean bval) { disable = bval; }
  boolean isDisable() { return disable; }
 
  void setHighlight(boolean bval) { highlight = bval; }
  boolean isHighlight() { return highlight; }
 
  boolean containsMouse()
  {
    if(!isDisable())
      if (mouseX > pos.x && mouseX < pos.x + tWidth && mouseY > pos.y && mouseY < pos.y + size )
        return true;
    
    return false;
  }
}

public class Sprite
{
    int x,y;
    PImage img;
    float s;
    
    int layer;
    
    public Sprite( PImage img, int x, int y, float s, int layer )
    {
        this.img = img;
        this.x = x;
        this.y = y;
        this.s = s;
        this.layer = layer;
    }

    public void moveBy( int x, int y)
    {
       this.x += x;
       this.y += y; 
    }

    public void draw()
    {
        image( img, x, y, img.width*s, img.height*s); 
        //image( img, x, 720 - y - img.height * s, img.width * s, img.height * s);
    }
    
    public boolean isVisible()
    {
        return x + img.width * s > 0;
    }
}
