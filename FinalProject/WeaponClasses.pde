// A weapon with certain parameters
// Want to define weapons in XML with certain parameters????
class Weapon
{
  private int rofRPM;       // fire rate in RPM
  private int projVel;      // projectile velocity (in m/s)
  private int weaponType;   // what type of ship is this? (from XML)
  private float damage;       // how much damage does this weapon do?
  private String projType;  // what type of projectile this fires?
  
  private int lastShotTime = 0;  // time when the last shot was fired
  private Projectile remote_proj;      // actual projectile that's been remotely fired
  
  private Ship ship;        // the ship that owns this weapon
  
  Weapon(Ship eShip, int eWeapon)
  {
    weaponType = eWeapon;
    rofRPM = getWeaponType().GetRateOfFire();
    projVel = getWeaponType().GetBulletVelocity();
    damage = getWeaponType().GetDamage();
    projType = getWeaponType().GetProjectileType();
    ship = eShip;
    
    remote_proj = null;
    
    println(projType);
  }
  
  public WeaponEntry getWeaponType() { return GetGameWeaponEntry(weaponType); }    // returns the ShipEntry associated with this ship
  
  private float getCooldownInMilliseconds() { return (float) NUM_MILLIS_IN_SEC / ((float)rofRPM / 60); }
  
  public int GetRateOfFire() { return rofRPM; }
  public int GetProjectileVelocity() { return projVel; }
  public Ship getShip() { return ship; }
  public void SetRemoteProjectile(Projectile proj) { remote_proj = proj; }
  
  boolean canFire()
  {
    return lastShotTime <= 0 || (millis() - lastShotTime > getCooldownInMilliseconds());
  }
  
  void fire(Entity ent)
  {
    if(canFire())
    {
      lastShotTime = millis();  // save the current time
      
      PlaySound("shoot.mp3");
      
      float pos_x = getShip().getX();
      float pos_y = getShip().getY() + getShip().getSizeY() / 2;
      float vel_x = getShip().isHuman() ? projVel : -projVel;
      float vel_y = 0;
      boolean enemy = !getShip().isHuman();
      
      int projID = GetProjectileTypeID(projType);
      
      // Is this a volley?
      if(getWeaponType().GetVolley() >= 2)
      {
        int num_missiles = getWeaponType().GetVolley();
        
        // initial start of the y for the missile volley
        pos_y -= int(num_missiles / 2) * GetGameProjectileEntry(projID).GetSizeY();
        
        for(int i = 0; i < num_missiles; i++)
        {          
          Projectile newProjectile = new Projectile(this, projID, pos_x, pos_y, damage, vel_x, vel_y, enemy);
          game.getGameEntities().add(newProjectile);
          
          pos_y += GetGameProjectileEntry(projID).GetSizeY();
        }
      }
      else
      {        
          Projectile newProjectile = new Projectile(this, projID, pos_x, pos_y, damage, vel_x, vel_y, enemy);
          
          // Weapon fires a remote projectile and a projectile hasn't been fired yet!
          if(remote_proj == null && getWeaponType().IsRemote())
          {
            remote_proj = newProjectile;
            newProjectile.SetCollide(false);    // remote projectiles don't collide
          }
          // Weapon is a remote weapon and a projectile has been fired
          else if(getWeaponType().IsRemote())
          {
            remote_proj.remote_detonate();
            remote_proj = null;
            return;  // get out!!!
          }
            
          game.getGameEntities().add(newProjectile);
      }
    }
  }
}
