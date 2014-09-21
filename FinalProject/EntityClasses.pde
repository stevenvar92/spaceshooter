// A base entity
// Planned to be used as a parent class - everything is an Entity, but all entities are different types (player, enemy, obstacle, etc.)
// Entities have movement abilities but no real properties

class Entity
{
  protected PVector pos;             // position vector
  protected PVector vel;             // velocity vector
  protected float size_x;            // size (x) - bounding box around object
  protected float size_y;            // size (y) - bounding box around object
  protected float speed_x;           // speed (x) - determines how fast velocity will be
  protected float speed_y;           // speed (y) - determines how fast velocity will be  
  protected PImage graphic;          // image to display (to-do: animation???)
  protected boolean bDelayedDeath;   // flag the entity for delayed death (to be killed when validate() is run!
  protected boolean bCollides;        // can this entity collide with stuff?
  
  Entity(float x, float y)
  {
    pos = new PVector(x, y);
    vel = new PVector(0.0, 0.0);
    bDelayedDeath = false;
    bCollides = true;
  }
  
  Entity(float x, float y, float velx, float vely)
  {
    pos = new PVector(x, y);
    vel = new PVector(velx, vely);
    bDelayedDeath = false;
  }
  
  void initGraphics(String filename)
  {
    graphic = Custom_LoadImage(filename);
    
    if(graphic != null)
    {
      graphic.resize((int)getSizeX(), (int)getSizeY());    // resize the player's sprite to a % of the the screen
    }
  }
  
  // Uninits the object and kills it
  void kill() { game.destroy(this); }
  
  void update(){}
  
  void validate()
  {
    if(isDelayedDeath())
      kill();
  }
  
  void draw(float norm)
  {
    // Interpolate where we're supposed to be drawn!
    float display_x = pos.x * ScreenXRatio();
    float display_y = pos.y * ScreenYRatio();
    
    float display_size_x = size_x * ScreenXRatio();
    float display_size_y = size_y * ScreenXRatio();    // Scaling by a uniform to keep shapes intact. Not perfect but will do
    
    // INTERPOLATION
    // We don't want this when the game is paused since objects will be stationary (but a velocity is still attached to them).
    if(!game.isPaused())
    {
      display_x += (vel.x / NUM_UPDATES_PER_SEC * norm);
      display_y += (vel.y / NUM_UPDATES_PER_SEC * norm);
    }
    
    if(isBoundaryLockedX())
    {
      display_x = max(0, display_x);
      display_x = min(width - display_size_x, display_x);
    }
    if(isBoundaryLockedY())
    {
      display_y = max(0, display_y);
      display_y = min(height - display_size_y, display_y);
    }
    if(graphic != null)
    {
      image(graphic, display_x, display_y, display_size_x, display_size_y);
    }
    // display a red rectangle
    else
    {
      noStroke();
      fill(#FF0000);
      rect(display_x, display_y, display_size_x, display_size_y);
    }
    
    outline(getCollisionBox());
  }
  
  public PVector getPosition() { return pos; }
  public PVector getVelocity() { return vel; }
  
  public float getX() { return pos.x; }
  public float getY() { return pos.y; }
  
  public float getSizeX() { return size_x; }
  public float getSizeY() { return size_y; }
  
  public float getSpeedX() { return speed_x; }
  public float getSpeedY() { return speed_y; }
  
  public void setSpeedX(float value) { speed_x = value; }
  public void setSpeedY(float value) { speed_y = value; }
  public void setDelayedDeath(boolean bValue) { bDelayedDeath = bValue; }
  
  public boolean isProjectile()   { return false; }
  public boolean isShip()         { return false; }
  public boolean isEnemy()        { return false; }
  public boolean isHuman()        { return false; }
  public boolean isDelayedDeath() { return bDelayedDeath; }
  
  public boolean isBoundaryLockedX() { return false; }
  public boolean isBoundaryLockedY() { return false; }
  
  public void damage(float damage) { }                    // this is a flaw in the design. Entities shouldn't take damage, but for a global collide() function to work, this must happen. :(
  public void collide(Entity otherEnt) { }
  
  public void SetCollide(boolean bVal) { bCollides = bVal; }
  public boolean IsCollide() { return bCollides; }
  
  public boolean canCollide(Entity other)  
  {
    if(this == other) return false;
    if(!IsCollide()) return false;    // collision is disabled for this entity?
    
    return true;
  }
  
  // Return the collision rectangle for this entity
  Rectangle getCollisionBox()
  {
    // We can run into the problem that if an object is moving too fast and is too small it might miss a target by accident
    float left_x = getX();
    float top_y = getY();
    float size_x = getSizeX();
    float size_y = getSizeY();
    
    if(vel.x > 0)  // moving right
    {
      left_x += (vel.x / NUM_UPDATES_PER_SEC / 2);
      size_x += vel.x / NUM_UPDATES_PER_SEC;
    }
    else if(vel.x < 0)  // moving left
    {
      left_x += (vel.x / NUM_UPDATES_PER_SEC / 2);
      size_x += -vel.x / NUM_UPDATES_PER_SEC;
    }
    if(vel.y < 0)  // moving up
    {
      top_y += (vel.y / NUM_UPDATES_PER_SEC/ 2);
      size_y += -vel.y / NUM_UPDATES_PER_SEC;
    }
    else if(vel.y > 0)
    {
      top_y += (vel.y / NUM_UPDATES_PER_SEC / 2);
      size_y += vel.y / NUM_UPDATES_PER_SEC;
    }
    
    return new Rectangle((int)left_x, (int)top_y, (int)size_x, (int)size_y);
  }
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
// Class Name: Ship
// - Extended class of Entity
// - Defines attributes of both a player and an enemy
// - can differentiate the two in many ways
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
class Ship extends Entity
{  
  private float health;
  private float shield;
  
  private int lastHitTime;         // time we were last hit
  private int shieldRechargeDelay; // time delay in ms before shield recharges
  private int shieldRechargeTime;  // time in ms for shield to fully recharge (from 0) 
  
  private int shipType;            // what type of ship is this? (from the XML)
  
  private ShipAI ship_ai;        // AI for ships. Player will have an AI, but it won't be functional.
  
  // Loadout
  ArrayList<Weapon> weaponList;    // our available weapons
  
  Ship(int eShip, float x, float y, int AIType)
  {
    super(x, y);
    
    shipType = eShip;
    
    // Health
    health = getShipType().GetHealth();
    shield = getShipType().GetShield();
    
    size_x = getShipType().GetSizeX();
    size_y = getShipType().GetSizeY();
    
    speed_x = getShipType().GetSpeedX();
    speed_y = getShipType().GetSpeedY();
    
    shieldRechargeDelay = 3000;
    shieldRechargeTime = getShipType().GetShieldRecharge();
    
    super.initGraphics(getShipType().GetImageFile());
    
    ship_ai = new ShipAI(this, AIType);      // init an EnemyAI for this Ship. Humans will have it, but it won't do anything.
    
    // Loadout
    weaponList = new ArrayList<Weapon>();
  }
  
  public void AddWeapon(int weaponType)
  {
    if(weaponType == -1) return;
    
    weaponList.add(new Weapon(this, weaponType));
  }
  
  public ShipEntry getShipType() { return GetGameShipEntry(shipType); }    // returns the ShipEntry associated with this ship
  public boolean isHuman() { return (this == game.getPlayer()); }
  public boolean isShip()  { return true; }
  public Weapon getPrimary()
  {
    if(weaponList.size() >= 1)
      return weaponList.get(0);
    else
      return null;
  }
  public Weapon getSecondary()
  {
    if(weaponList.size() >= 1)
      return weaponList.get(1);
    else
      return null;
  }
  
  public boolean isEnemy() { return !isHuman(); }
  
  public float GetMaxHealth() { return getShipType().GetHealth(); }  // note: if we have a health bonus powerup, it scale percentage-wise based on this value
  public float GetMaxShield() { return getShipType().GetShield(); }  // note: if we have an overshield powerup, it scale percentage-wise based on this value
  
  // BEGIN GAMEPLAY
  
  // Health
  public float getHealthRemaining() { return max(0, health); }
  public void setHealthRemaining(float value){ health = max(0, value); }
  public void changeHealthRemaining(float change) { setHealthRemaining(max(0, getHealthRemaining() + change)); }
  public boolean isAlive() { return health > 0; }
  
  // Shield
  public float getShieldRemaining() { return max(0, shield); }
  public void setShieldRemaining(float value) { shield = max(0, value); }
  public void changeShieldRemaining(float change) { setShieldRemaining(max(0, getShieldRemaining() + change)); }
  public boolean isShieldActive() { return shield > 0; } 
  public float getShieldRecharge() { return shieldRechargeTime; }
  
  // Damage the player. Shield goes first, then health.
  public void damage( float damage )
  {    
    if(isHuman())
    {
      //println("we are taking " + damage + " damage!");
    }
    
    float shield_damage = min(damage, getShieldRemaining());
    
    changeShieldRemaining(-shield_damage);
    damage -= shield_damage;    // subtract damage from the shield
    
    lastHitTime = millis();
    
    // if there is still damage left to dish out, damage health!
    if(damage > 0)
      changeHealthRemaining(-damage);
    
    // kill the ship if the health runs out!
    if(getHealthRemaining() <= 0)
    {
      setDelayedDeath(true);
      PlaySound("explosion2.mp3"); 
     
      // Thing was an enemy - award player XP based on a formula
      if(isEnemy())
      {
        int baseXP = 25;
        
        ShipEntry shipInfo = GetGameShipEntry(shipType);
        
        baseXP *= shipInfo.GetXPModifier();
        baseXP /= 100;
        
        profile.changeLifetimeExperience(baseXP);
      } 
    }
  }
  
  // This ship is dying - what happened?
  void kill()
  {
    // We're not human
    if(!isHuman())
    {      
      super.kill();
    }
    // We are human - what happens?
    else
    {
      game.exit();
    }
  }
  
  void fire()
  {
    if(!focused) { return; }
    if(SHOOT_PRIMARY)
    {
      if(getPrimary() != null)
        getPrimary().fire(this);
    }
    if(SHOOT_SECONDARY)
    {
      if(getSecondary() != null)
        getSecondary().fire(this);
    }
  }
  
  void resetFiring()
  {
    SHOOT_PRIMARY = false;
    SHOOT_SECONDARY = false;
  }
  
  // We collide with another entity!
  public void collide(Entity otherEnt)
  {
    if(otherEnt.isHuman())
    {
      // Human players take damage when they collide with enemies
      if(otherEnt.isHuman()) otherEnt.damage(3.0f);
        
      PlaySound("hit_hurt.mp3");
    }
  }
  
  void recharge()
  {
    if(getShieldRecharge() <= 0) return;      // don't have a recharge time, return
    
    if(getShieldRemaining() < GetMaxShield())
    {
      int currentTime = millis();
      if(currentTime - lastHitTime >= shieldRechargeDelay)
      { 
        Float amountRecharged = GetMaxShield() / (getShieldRecharge() / 1000) / NUM_UPDATES_PER_SEC;  // how much we recharge each frame
        
        if(getShieldRemaining() + amountRecharged > GetMaxShield())
          amountRecharged = GetMaxShield() - getShieldRemaining();
          
        changeShieldRemaining(amountRecharged);
      }
    }
  }
  
  // Move the player
  void move()
  {
    // If we are not focused on the window, return
    if(!focused) { resetMovement(); return; }
    
    pos.x += vel.x / NUM_UPDATES_PER_SEC;
    pos.y += vel.y / NUM_UPDATES_PER_SEC;
    
    // Bounds checking
    // we hit the left side of the screen
    if(pos.x < 0)
    {
      if(isBoundaryLockedX())
      {
        pos.x = 0;
      }
      else
      {
        setDelayedDeath(true);
      }
    }
    // We hit the right side of the screen
    else if(pos.x + size_x > NUM_METERS_WIDTH)
    {
      if(isBoundaryLockedX())
      {
        pos.x = NUM_METERS_WIDTH - size_x;
      }
      else
      {
        // do nothing for enemies at the moment...
      }
    }
    if(pos.y < 0)
    {
      if(isBoundaryLockedY())
      {
        pos.y = 0;
      }
    }
    else if(pos.y + size_y > NUM_METERS_HEIGHT)
    {
      if(isBoundaryLockedY())
      {
        pos.y = NUM_METERS_HEIGHT - size_y;
      }
    }
  }
  
  public boolean isBoundaryLockedX()
  {
    if(isHuman())
      return true;
    
    return false;
  }
  
  public boolean isBoundaryLockedY()
  {
    if(isHuman())
      return true;
      
    return false;
  }
  
  // Resets movement to initial values (stationary, with no velocity in any direction).
  void resetMovement()
  {
    MOVE_UP = false;
    MOVE_DOWN = false;
    MOVE_LEFT = false;
    MOVE_RIGHT = false;
    
    vel.x = 0;
    vel.y = 0;
  }
  
  // Helper function to determine if two entities can actually collide
  boolean canCollide(Entity other)
  {
    if(!super.canCollide(other)) return false;
    if(!isEnemy() && !other.isEnemy()) return false;  // for now, allied stuff (projectiles, etc.) ignore collision with each other! (if we ever add MP support, this has to change)
    if(isEnemy() && other.isEnemy()) return false;    // for now, enemies ignore collision with each other! (may change in the future - special flag?)
    
    return true;
  }
  
  // END GAMEPLAY
  ///////////////////////////////////////////////////////////////////////
  // BEGIN INPUT
  
  // Movement variables
  public boolean MOVE_UP = false;
  public boolean MOVE_DOWN = false;
  public boolean MOVE_LEFT = false;
  public boolean MOVE_RIGHT = false;
  
  // Shooting variables
  public boolean SHOOT_PRIMARY = false;
  public boolean SHOOT_SECONDARY = false;
  
  // END INPUT
  ///////////////////////////////////////////////////////////////////////
  // BEGIN GRAPHICS
  
  void update()
  {      
    ship_ai.think();
    
    move();            // move the object
    fire();            // fire any weapons
    recharge();        // recharge our shields?
  }
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

// A projectile.
// Fired from a weapon, which defines the projectile's speed and damage
class Projectile extends Entity
{
  private boolean bEnemy;
  private float damage;                  // damage the projectile does. This will be loaded in from Weapon XML
  
  private int projectileType;            // what type of projectile is this? (from the XML)x
  
  private Weapon weapon;                 // weapon this projectile was fired from
  
  Projectile(Weapon weap, int projType, float x, float y, float dmg, float spdX, float spdY, boolean enemy)
  {
    super(x, y);
    
    weapon = weap;
    projectileType = projType;
    
    size_x = getProjectileInfo().GetSizeX();
    size_y = getProjectileInfo().GetSizeY();
    damage = dmg;
    
    speed_x = spdX;
    speed_y = spdY;
    bEnemy = enemy;
    
    vel.x = getSpeedX();
    vel.y = getSpeedY();
    
    super.initGraphics(getProjectileInfo().GetImageFile());
  }
  
  public ProjectileEntry getProjectileInfo() { return GetGameProjectileEntry(projectileType); }
  public boolean isProjectile() { return true; }
  public boolean isEnemy() { return bEnemy; }
  public float getDamage() { return damage; }
  
  void move()
  {
    pos.x += vel.x / NUM_UPDATES_PER_SEC;
    pos.y += vel.y / NUM_UPDATES_PER_SEC;
    
    // Kill us if we've reached the end of the screen
    if(pos.x > NUM_METERS_WIDTH || pos.x < 0 || pos.y < 0 || pos.y > NUM_METERS_HEIGHT)
    {
      preKill();
    }
  }
  
  public void collide(Entity otherEnt)
  {
    // Projectiles deal damage to ships they collide with.
    if(otherEnt.isShip())
    {
      otherEnt.damage(getDamage());
    }
    
    // Projectiles that can penetrate objects do not die on contact with another obstacle
    if(!getProjectileInfo().isCanPenetrate())
    {
      preKill();
    }
  }
  
  public void remote_detonate()
  {
    preKill();
    
    // Inefficient but only an order-n operation because we only care if the entities intersect the circle!
    for(int i=0; i < game.getGameEntities().size(); i++)
    {
      Entity other = game.getGameEntities().get(i);
      if(other == null) continue;
      if(other.isEnemy() && isEnemy()) continue;  // don't accidentally blow up ourselves!
      if(!other.isEnemy() && !isEnemy()) continue;  
      
      Rectangle r1 = new Rectangle(int(pos.x - weapon.getWeaponType().GetBlastRadius()/2), int(pos.y - weapon.getWeaponType().GetBlastRadius()/2), (int)weapon.getWeaponType().GetBlastRadius(), (int)weapon.getWeaponType().GetBlastRadius());
      
      if(r1.intersects(other.getCollisionBox()))
      {
        other.damage(getDamage());
      }
    }
  }
  
  // Pre-kill the projectile. Makes sure things are cleaned up nicely.
  public void preKill()
  {
    weapon.SetRemoteProjectile(null);  // if this was a remote projectile, set the firing weapon to null
    setDelayedDeath(true);
  }
  
  boolean canCollide(Entity other)
  {
    if(!super.canCollide(other)) return false;
    if(!isEnemy() && !other.isEnemy()) return false;  // for now, allied stuff (projectiles, etc.) ignore collision with each other! (if we ever add MP support, this has to change)
    if(isEnemy() && other.isEnemy()) return false;    // for now, enemies ignore collision with each other! (may change in the future - special flag?)
    if(other.isProjectile()) return false;            // do not collide with other projectiles
    if(other.isDelayedDeath()) return false;          // thing is already dead, we don't collide with it
    
    return true;
  }
  
  void update()
  {
    move();
  }
}
