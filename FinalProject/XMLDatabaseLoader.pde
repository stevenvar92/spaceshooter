public class DatabaseLoader
{
  final String XMLDirectory = "./XML/";
  private XML xml;
  
  DatabaseLoader()
  {
    xml = null;
  }
  
  // This function will load the game data into the various ArrayLists - if this fails, they'll be unpopulated. If they're unpopulated, then the game will crash!!!!
  void LoadGameData()
  {
    debugPrint("Loading game database...");
    int time = millis();
    
    DB_LoadFile("ships.xml");
    
    DB_LoadFile("ships.xml");
    DB_LoadTable_Ship(GetGameShipEntries());
    
    DB_LoadFile("projectiles.xml");
    DB_LoadTable_Projectile(GetGameProjectileEntries());
    
    DB_LoadFile("weapons.xml");
    DB_LoadTable_Weapon(GetGameWeaponEntries());
    
    debugPrint("Database loading took " + (millis() - time) + " ms");
  }
  
  // Load an XML file ready to be read
  public boolean DB_LoadFile(String filename)
  {
    xml = loadXML(XMLDirectory + filename);
    if(xml == null)
    {
      println("Error loading database file: " + filename);
      return false;
    }
    return true;
  }
  
  // Retrives an integer value from the specified XML column name from the specified Row
  public int DB_GetInt(XML row, String colname)
  {
    XML column = row.getChild(colname);
    if(column == null)
    {
      return -1;
    }
    
    String rtn = column.getContent();
    return parseInt(rtn);
  }
  
  // Retrives a boolean value from the specified XML column name from the specified Row
  public boolean DB_GetBoolean(XML row, String colname)
  {
    XML column = row.getChild(colname);
    if(column == null)
    {
      return false;
    }
    
    String rtn = column.getContent();
    return parseBoolean(rtn);
  }
  
  // Retrives an float value from the specified XML column name from the specified Row
  public float DB_GetFloat(XML row, String colname)
  {
    XML column = row.getChild(colname);
    if(column == null)
    {
      println("Error: invalid column name: " + colname);
      return 0.0f;
    }
    
    String rtn = column.getContent();
    return parseFloat(rtn);
  }
  
  // Retrives an string value from the specified XML column name from the specified Row
  public String DB_GetString(XML row, String colname)
  {
    XML column = row.getChild(colname);
    if(column == null)
    {
      println("Error: invalid column name: " + colname);
      return "";
    }
    
    return column.getContent();
  }
  
  ///////////////////////////////////////////////////////////////////////////
  // So templates in Java don't seem to work as well as they do in C++.
  // If you add a new Entry type, you must overload this function. Copy-pasting the code and changing the entry object will suffice.
  // What the hell? You can't overload it? Oh well, just suffix it with the class name. This is ridiculous.
  // Make sure your new Entry has a LoadData function!
  
  // Loads a specified table.
  public void DB_LoadTable_Ship(ArrayList<ShipEntry> array)
  {
    ShipEntry obj;
    XML[] rows = xml.getChildren("Row");
    for(int idx_row = 0; idx_row < rows.length; idx_row++)
    {
      obj = new ShipEntry();
      obj.LoadData(rows[idx_row]);        // load it's XML data in to the object
      array.add(obj);                     // add this object entry into the game's data array
    }
  }
  
  // Loads a specified table.
  public void DB_LoadTable_Projectile(ArrayList<ProjectileEntry> array)
  {
    ProjectileEntry obj;
    XML[] rows = xml.getChildren("Row");
    for(int idx_row = 0; idx_row < rows.length; idx_row++)
    {
      obj = new ProjectileEntry();
      obj.LoadData(rows[idx_row]);        // load it's XML data in to the object
      array.add(obj);                     // add this object entry into the game's data array
    }
  }
  
  // Loads a specified table.
  public void DB_LoadTable_Weapon(ArrayList<WeaponEntry> array)
  {
    WeaponEntry obj;
    XML[] rows = xml.getChildren("Row");
    for(int idx_row = 0; idx_row < rows.length; idx_row++)
    {
      obj = new WeaponEntry();
      obj.LoadData(rows[idx_row]);        // load it's XML data in to the object
      array.add(obj);                     // add this object entry into the game's data array
    }
  }
}
