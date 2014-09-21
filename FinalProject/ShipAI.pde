final int NO_AI_TYPE = -1,                // No AI Type (does nothing)
          AI_TYPE_BASIC = 0,              // Basic AI that moves left in a straight line
          AI_TYPE_BASIC_AGGRESSIVE = 1;   // Variation of basic AI where the enemy will attempt to line up with the player

class ShipAI
{
  Ship ourShip;
  PVector dest_pos;  // a destination position
  int aiType;
  
  ShipAI(Ship ship, int _aiType)
  {
    ourShip = ship;
    aiType = _aiType;
  }
  
  private Ship GetShip() { return ourShip; }
  public int getAIType() { return aiType; }
  
  private final int DIRECTION_LEFT = 0;
  private final int DIRECTION_RIGHT = 1;
  private final int DIRECTION_UP = 2;
  private final int DIRECTION_DOWN = 3;
  
  private void moveDirection(int direction)
  {
    switch(direction)
    {
      case DIRECTION_LEFT:
        GetShip().getVelocity().x = -GetShip().getSpeedX();
        break;
      case DIRECTION_RIGHT:
        GetShip().getVelocity().x = GetShip().getSpeedX();
        break;
      case DIRECTION_UP:
        GetShip().getVelocity().y = -GetShip().getSpeedY();
        break;
      case DIRECTION_DOWN:
        GetShip().getVelocity().y = GetShip().getSpeedY();
        break;
    }
  }
  
  private void killVelX() { GetShip().getVelocity().x = 0; }
  private void killVelY() { GetShip().getVelocity().y = 0; }
  
  void fire()
  {
    GetShip().SHOOT_PRIMARY = true;
  }
  
  public void think()
  {
    switch(getAIType())
    {
      case NO_AI_TYPE:
        // do nothing
        break;
      case AI_TYPE_BASIC:
        moveDirection(DIRECTION_LEFT);
        break;
      case AI_TYPE_BASIC_AGGRESSIVE:
        moveDirection(DIRECTION_LEFT);
        fire();
        
        if(game.getPlayer().getPosition().y - GetShip().getSpeedY() > GetShip().getPosition().y) moveDirection(DIRECTION_DOWN);
        else if(game.getPlayer().getPosition().y + GetShip().getSpeedY() < GetShip().getPosition().y) moveDirection(DIRECTION_UP);
        else killVelY();
        break;
      default:
        println("Error - incorrect AI Type!");
        break;
    }
  }
}
