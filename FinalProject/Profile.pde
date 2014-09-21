public static class Profile implements Serializable
{
  transient final int MAX_LEVEL = 10;
  transient final int MAX_EXPERIENCE = 1416900;    // Manual summation of the lookup table. If something changes down there, change it here
  
  // Lookup table to store required XP for next level
  transient int[] XPForLevel =
  {
    100,      // From 0 to 1
    400,      // From 1 to 2
    1000,     // From 2 to 3
    2400,     // From 3 to 4
    5000,     // From 4 to 5
    10000,    // From 5 to 6
    48000,    // From 6 to 7
    100000,   // From 7 to 8
    250000,   // From 8 to 9
    1000000   // From 9 to 10
  };
  
  public int level;                          // Stores the level of the profile
  public int experience;                     // Stores the (total) experience of the profile
  public int[] weapons;                      // Stores the weapons we have equipped on this profile
  
  Profile(int _level, int _xp, int primaryType, int secondaryType)
  {
    level          = _level;
    experience     = _xp;
    
    // Array size of two because we can only carry one primary and one secondary at a time!
    weapons = new int[2];
    
    if(primaryType < 0)
    {
      println("Error! Primary cannot be less than zero! Setting default value 0");
      primaryType = 0;
    }
    
    
    weapons[0] = primaryType;    // should always be valid!
    weapons[1] = secondaryType;  // if we have no weapon, -1 is passed in
  }
  
  public int getLevel() { return level; }
  private void setLevel(int val)
  {
    if(val > MAX_EXPERIENCE)
    {
      val = MAX_EXPERIENCE;
    }  
    
    level = val;
  }

  private void changeLevel(int val)                        // can't be de-leveled
  {
    if(val > 0)
      setLevel(getLevel() + val);
  }
 
  public boolean hasSecondary() { return weapons[1] >= 0; } 
  
  public int getLifetimeExperience() { return experience; }
  private void setLifetimeExperience(int val) { experience = val; }  // private for security reasons (don't want to accidentally call and erase lifetime experience)
  public void changeLifetimeExperience(int xp)                       // will not ever reduce lifetime experience
  {
    if(xp > 0)
      setLifetimeExperience(getLifetimeExperience() + xp);
      
    checkLevel();
  }
  
  public int getCurrentLevelExperience()
  {
    int xp = getLifetimeExperience();
    
    // Reduce lifetime experience from experience we need
    for(int i = getLevel()-1; i >= 0; i--)
    {
      xp -= GetXPRequiredForNextLevel(i);
    }
    
    return xp;
  }
  
  public int getExperienceForNextLevel()
  {    
    int rtn = 0;
    for(int i = 0; i <= getLevel(); i++)
      rtn += GetXPRequiredForNextLevel(i);
    
    return rtn;
  }
  
  public int GetXPRequiredForNextLevel(int iLevel)
  {
    if(iLevel >= MAX_LEVEL) return 0;
    if(iLevel < 0) return 0;
    
    return XPForLevel[iLevel];
  }
  
  public void checkLevel()
  {
    if(getLifetimeExperience() > getExperienceForNextLevel())
    {
      changeLevel(1);
    }
  }
};
