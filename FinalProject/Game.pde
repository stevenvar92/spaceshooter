// Game class
// Stores information about the currently running game
// Only refers to a currently running game, not the external application (i.e. menus...)
class Game
{  
  // Data structures useful for gameplay
  private LinkedList<Entity> entities;                                                          // stores all enemies
  private Quadtree colTree = new Quadtree(0, new Rectangle(0,0,NUM_METERS_WIDTH, NUM_METERS_HEIGHT));   // quadtree for collision detection
  
  private int start_time;
  private int last_wave_spawn;
  private int time_between_waves;
  
  private boolean paused;
  
  Ship getPlayer() { return (Ship) entities.get(0); }
  Integer getTotalNumEntities() { return entities.size(); }
  
  LinkedList<Entity> getGameEntities() { return entities; }
  
  Game()
  {    
  }
  
  void Init()
  {
    entities = new LinkedList<Entity>();
    
    reset();
    start();
  }
  
  void Uninit()
  {
    reset();
  }
  
  void reset()
  {
    entities.clear();
    colTree.clear();
    start_time = 0;
    last_wave_spawn = 0;
    time_between_waves = 0;
    paused = false;
  }
  
  // Starts the game.
  void start()
  {
    start_time = millis();
    last_wave_spawn = 0;
    time_between_waves = 5000;
    
    // The player always comes first!
    Ship player = addShip(0, (float)NUM_METERS_WIDTH/16, (float)NUM_METERS_HEIGHT/2, NO_AI_TYPE);
    
    // give the player a primary
    player.AddWeapon(profile.weapons[0]);
    
    // ...and a secondary
    if(profile.hasSecondary())
      player.AddWeapon(profile.weapons[1]);
  }
  
  // Exits a game
  void exit()
  {
    Uninit();
    SaveGame(this);  // check "Serialization file"
    ExitGame();  // once this is called, the game will be deleted. This should be the last thing done!
  }
  
  // Toggle between "Pause" and "Unpause" states
  void togglePause()
  {
    paused = !paused;
    
    if(isPaused())
    {
      music.pause();
    }
    else
    {
      music.play();
    }
  }
  
  boolean isPaused() { return paused; }
  
  // Time keeping functions
  int GetGameStartTime() { return start_time; }
  int GetGameCurrentTime() { return millis() - GetGameStartTime(); }
  
  // Create a new ship in the game.
  Ship addShip(int shipType, float pos_x, float pos_y, int aiType)
  {
    Ship newShip = new Ship(shipType, pos_x, pos_y, aiType);
    entities.add(newShip);
    return newShip;
  }
  
  // Accepts input
  void handleInput(int k, boolean bPressed)
  {
    switch(k)
    {
      case 'P':
        if(bPressed)
          togglePause();
        break;
      case 'Q':
        // let's not exit the game with 'Q' unless we're in debug
        if(debug)
          exit();
        break;
      default:
        // Actions that happen in both cases (pressing/releasing)
        input(keyCode, bPressed);  // move player
    }
  }
  
  // Accepts key input (k) and changes velocity in the direction. Prevents the player from moving left/right at the same time.
  void input(int k, boolean bPressed)
  {    
    if(!focused) return;  // do not accept input if we are not currently focused
    
    Ship player = getPlayer();
    
    // Movement
    if      ( k == UP     || k == 'w' || k == 'W' ) player.MOVE_UP     = bPressed;
    else if ( k == DOWN   || k == 's' || k == 'S' ) player.MOVE_DOWN   = bPressed;
    else if ( k == LEFT   || k == 'a' || k == 'A' ) player.MOVE_LEFT   = bPressed;
    else if ( k == RIGHT  || k == 'd' || k == 'D' ) player.MOVE_RIGHT  = bPressed;
   
    // Figure out how we're moving
    int iUpFactor     = player.MOVE_UP     ? -1 : 0;
    int iDownFactor   = player.MOVE_DOWN   ?  1 : 0;
    int iLeftFactor   = player.MOVE_LEFT   ? -1 : 0;
    int iRightFactor  = player.MOVE_RIGHT  ?  1 : 0;
    
    // Set the player's velocity. If we're currently moving in the opposite direction, don't do it.
    if (!player.MOVE_DOWN)  player.getVelocity().y = player.getSpeedY() * iUpFactor;
    if (!player.MOVE_UP)    player.getVelocity().y = player.getSpeedY() * iDownFactor; 
    if (!player.MOVE_RIGHT) player.getVelocity().x = player.getSpeedX() * iLeftFactor; 
    if (!player.MOVE_LEFT)  player.getVelocity().x = player.getSpeedX() * iRightFactor;
    
    // Actions
    if ( k == ' '     || k == 'Z'  || k == 'z') player.SHOOT_PRIMARY = bPressed;
    if ( k == CONTROL || k == 'X'  || k == 'x') player.SHOOT_SECONDARY = bPressed;
  }
  
  void drawInterface()
  {
    // Set up the user interface
    float offsetX       = 50;      // the offset in the x direction from the left of the screen.
    float offsetY       = 20;      // the offset in the y direction from the top of the screen.
    float barSizeX      = 150;     // size of the box
    float barSizeY      = 10;      // size of the box
    float barSpacing    = 30;      // spacing between boxes
    float health = getPlayer().getHealthRemaining();
    float shield = getPlayer().getShieldRemaining();
    float xp = profile.getCurrentLevelExperience();
    
    float healthPercent = 0;
    float shieldPercent = 0;
    float xpPercent = 0;
    
    if(getPlayer().GetMaxHealth() >= 0.0f)
      healthPercent = 100 * health / getPlayer().GetMaxHealth();
    if(getPlayer().GetMaxShield() >= 0.0f)
      shieldPercent = 100 * shield / getPlayer().GetMaxShield();
    xpPercent = 100 * xp / profile.GetXPRequiredForNextLevel(profile.getLevel());

    textSize(24);
    text(profile.getLevel() + 1, offsetX / 2, 30);

    // health bar
    fill(COLOR_HEALTH);
    noStroke();
    rect(offsetX, offsetY, barSizeX * (healthPercent / 100), 5 * barSizeY / 4);
    
    // shield bar
    fill(COLOR_SHIELD);
    noStroke();
    rect(offsetX, offsetY - barSizeY, barSizeX * (shieldPercent / 100), 3 * barSizeY / 4);
    
    // xp bar
    fill(COLOR_XP);
    noStroke();
    rect(offsetX, offsetY + barSizeY + 5, barSizeX * (xpPercent / 100), barSizeY / 2);
    
    if(debug)
    {
      PFont font = Custom_LoadFont("Verdana-Bold-16.vlw");
      textFont(font, 16);
      text("x: " + getPlayer().getPosition().x + ", y: " + getPlayer().getPosition().y, 0, height - 40);
      text("FPS: " + frameRate, 0, height - 20);
    }
  }
  
  // Checks collision for all objects in the world
  void checkCollision()
  {
    colTree.clear();
    for(int i = 0; i < entities.size(); i++)
    {
      colTree.insert(entities.get(i));
    }
        
    ArrayList<Entity> returnObjects = new ArrayList<Entity>();
    for(int i = 0; i < entities.size(); i++)
    {
      Entity pLoopEntity = entities.get(i);
      
      returnObjects.clear();
      colTree.retrieve(returnObjects, entities.get(i));
      
      for(int x = 0; x < returnObjects.size(); x++)
      {
        Entity pOtherEntity = returnObjects.get(x);
        
        if(isCollide(pLoopEntity, pOtherEntity))
        {
          pLoopEntity.collide(pOtherEntity);
        }
      }
    }
  }
  
  void generateEnemies()
  {
    if(timeToGenerateNextWave())
    {
      last_wave_spawn = GetGameCurrentTime();
      
      // Pick a formation time
      int formation = int(random(0, NUM_FORMATIONS));
      float random_y = random(0, NUM_METERS_HEIGHT);
      createFormation(formation, random_y);
      
      println("Created formation", formation, "at position", random_y);
    }
  }
  
  boolean timeToGenerateNextWave()
  {
    return ((GetGameCurrentTime() - last_wave_spawn)) > time_between_waves;
  }
  
  boolean destroy(Entity ent)
  {
    return entities.remove(ent);
  }
  
  // Update the game world
  void update()
  {
    // If we are paused, do not update the game world!
    if(isPaused())
      return;
    
    checkCollision();
    generateEnemies();
    
    // update entities
    for(int i=0; i < entities.size(); i++)
    {
      //debugDrawCollision(entities.get(i).getCollisionBox());
      entities.get(i).update();    // beware! objects can get removed here!!!
      entities.get(i).validate();
    }
  }
  
  void draw(float norm)
  {
    // Draw all the entities
    for(int i=0; i < entities.size(); i++)
    {
      entities.get(i).draw(norm);
    }
    drawInterface();
    
    if(debug)
      colTree.draw();
  }
}
