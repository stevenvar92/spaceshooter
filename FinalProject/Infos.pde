// Stores information about definitions from the XMLs
// Base class which gets extended
class BaseInfo
{
  int id;
  String type;
  
  BaseInfo()
  {
    id = -1;
  }
  
  // Pass this database object a row
  boolean LoadData(XML row)
  {
    id     = dl.DB_GetInt(row, "ID");
    type   = dl.DB_GetString(row, "Type");
    
    return true;
  }
  
  int GetID() { return id; }
  String GetType() { return type; }
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

// Information about a single Projectile Entry
class ProjectileEntry extends BaseInfo
{
  private int sizex;
  private int sizey;
  private String imageFile;
  private boolean penetrate;
   
  ProjectileEntry()
  {
    sizex = 0;
    sizey = 0;
    imageFile = "";
  }
  
  // Pass this database object a row
  public boolean LoadData(XML row)
  {   
    if(!super.LoadData(row))
      return false;

    sizex             = dl.DB_GetInt(row, "SizeX");
    sizey             = dl.DB_GetInt(row, "SizeY");
    imageFile         = dl.DB_GetString(row, "ImageFile");
    penetrate         = dl.DB_GetBoolean(row, "CanPenetrate");
    
    return true;
  }
  
  public int GetSizeX() { return sizex; }
  public int GetSizeY() { return sizey; }
  public String GetImageFile() { return imageFile; }
  
  public boolean isCanPenetrate() { return penetrate; }
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
// Information about a single Ship Entry
class ShipEntry extends BaseInfo
{
  private float speedx;
  private float speedy;
  private float sizex;
  private float sizey;
  private float health;
  private float shield;
  private int shieldrecharge;
  private int xpmod;
  private String imageFile;
   
  ShipEntry()
  {
    speedx = 0.0f;
    speedy = 0.0f;
    sizex = 0;
    sizey = 0;
    health = 0.0f;
    shield = 0.0f;
    shieldrecharge = 0;
    xpmod = 0;
    imageFile = "";
  }
  
  // Pass this database object a row
  public boolean LoadData(XML row)
  {   
    if(!super.LoadData(row))
      return false;
    
    speedx          = dl.DB_GetFloat(row, "SpeedX");
    speedy          = dl.DB_GetFloat(row, "SpeedY");
    sizex           = dl.DB_GetFloat(row, "SizeX");
    sizey           = dl.DB_GetFloat(row, "SizeY");
    health          = dl.DB_GetFloat(row, "Health");
    shield          = dl.DB_GetFloat(row, "Shield");
    shieldrecharge  = dl.DB_GetInt(row, "ShieldRecharge");
    xpmod           = dl.DB_GetInt(row, "XPModifier");
    imageFile       = dl.DB_GetString(row, "ImageFile");
    
    return true;
  }
  
  public float GetSpeedX() { return speedx; }
  public float GetSpeedY() { return speedy; }
  public float GetSizeX() { return sizex; }
  public float GetSizeY() { return sizey; }
  public float GetHealth() { return health; }
  public float GetShield() { return shield; }
  public int GetShieldRecharge() { return shieldrecharge; }
  public int GetXPModifier() { return xpmod; }
  public String GetImageFile() { return imageFile; }
}

// Information about ships contained in the XMLs.
class ShipXMLEntries
{
  ArrayList<ShipEntry> shipEntries;
  
  ShipXMLEntries()
  {
    shipEntries = new ArrayList<ShipEntry>();
  }
  
  ArrayList<ShipEntry> GetEntries() { return shipEntries; }
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

// Information about ships contained in the XMLs.
class ProjectileXMLEntries
{
  ArrayList<ProjectileEntry> projectileEntries;
  
  ProjectileXMLEntries()
  {
    projectileEntries = new ArrayList<ProjectileEntry>();
  }
  
  ArrayList<ProjectileEntry> GetEntries() { return projectileEntries; }
}

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

// Information about a single Weapon Entry
class WeaponEntry extends BaseInfo
{
  private int rateoffire;
  private int bulletvelocity;
  private int volley;
  private float damage;
  private float blastradius;
  private String projectileType;
  private boolean remote;
  private boolean secondary;
   
  WeaponEntry()
  {
    rateoffire = 0;
    bulletvelocity = 0;
    projectileType = "";
  }
  
  // Pass this database object a row
  public boolean LoadData(XML row)
  {   
    if(!super.LoadData(row))
      return false;

    rateoffire       = dl.DB_GetInt(row, "RateOfFire");
    bulletvelocity   = dl.DB_GetInt(row, "BulletVelocity");
    volley           = dl.DB_GetInt(row, "Volley");
    damage           = dl.DB_GetFloat(row, "Damage");
    blastradius      = dl.DB_GetFloat(row, "BlastRadius");
    projectileType   = dl.DB_GetString(row, "ProjectileType");
    remote           = dl.DB_GetBoolean(row, "Remote");
    secondary        = dl.DB_GetBoolean(row, "IsSecondary");
    
    return true;
  }
  
  public int GetRateOfFire() { return rateoffire; }
  public int GetBulletVelocity() { return bulletvelocity; }
  public int GetVolley() { return volley; }
  public float GetDamage() { return damage; }
  public float GetBlastRadius() { return blastradius; }
  public String GetProjectileType() { return projectileType; }
  public boolean IsRemote() { return remote; }
  public boolean IsSecondary() { return secondary; }
}

// Information about ships contained in the XMLs.
class WeaponXMLEntries
{
  ArrayList<WeaponEntry> weaponEntries;
  
  WeaponXMLEntries()
  {
    weaponEntries = new ArrayList<WeaponEntry>();
  }
  
  ArrayList<WeaponEntry> GetEntries() { return weaponEntries; }
}

// Stupid hack function. I don't have time for clever workarounds anymore.
int GetProjectileTypeID(String type)
{  
  if(type.equals("PROJECTILE_NORMAL"))
  {
    return 0;
  }
  else if(type.equals("PROJECTILE_MISSILE"))
  {
    return 1;
  }
  else if(type.equals("PROJECTILE_LYNX_MISSILE"))
  {
    return 2;
  }
  else
  {
    return -1;
  }
}
