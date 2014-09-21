// This file will outline several formations that will randomly spawn, as well as the various AIs associated with them
// Don't be stupid. Update this list like a normal person and in order.
// I can 100% tell you this would be easier with C-style enums
// Make sure you know what you're doing before you touch this list!

final int FORMATION_BASIC               = 0,
          FORMATION_BASIC_MEDIUM        = 1,
          FORMATION_DOUBLE              = 2,
          FORMATION_BASIC_ATTACK        = 3,
          FORMATION_MEDIUM_ATTACK       = 4,
          NUM_FORMATIONS                = 5;
                 
void createFormation(int formation, float cy)
{
  Ship enemy;  // enemy object. addship() will return a Ship, this is used so we can add whatever weapons we want to whatever enemies
  
  switch(formation)
  {
    case FORMATION_BASIC:
      enemy = game.addShip(1, NUM_METERS_WIDTH, cy, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 50, cy, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 100, cy, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 150, cy, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 200, cy, AI_TYPE_BASIC);
      break;
    case FORMATION_BASIC_MEDIUM:
      enemy = game.addShip(1, NUM_METERS_WIDTH, cy, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 50, cy, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 100, cy, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 150, cy, AI_TYPE_BASIC);
      enemy = game.addShip(2, NUM_METERS_WIDTH + 200, cy, AI_TYPE_BASIC);
      enemy.AddWeapon(1);
      break;
    case FORMATION_DOUBLE:
      enemy = game.addShip(1, NUM_METERS_WIDTH, cy - 20, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 50, cy - 20, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 100, cy - 20, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 150, cy - 20, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 200, cy - 20, AI_TYPE_BASIC);
      
      enemy = game.addShip(1, NUM_METERS_WIDTH, cy + 20, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 50, cy + 20, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 100, cy + 20, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 150, cy + 20, AI_TYPE_BASIC);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 200, cy + 20, AI_TYPE_BASIC);
      break;
    case FORMATION_BASIC_ATTACK:
      enemy = game.addShip(1, NUM_METERS_WIDTH, cy, AI_TYPE_BASIC_AGGRESSIVE);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 50, cy, AI_TYPE_BASIC_AGGRESSIVE);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 100, cy, AI_TYPE_BASIC_AGGRESSIVE);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 150, cy, AI_TYPE_BASIC_AGGRESSIVE);
      enemy = game.addShip(1, NUM_METERS_WIDTH + 200, cy, AI_TYPE_BASIC_AGGRESSIVE);
      break;
    case FORMATION_MEDIUM_ATTACK: 
      enemy = game.addShip(2, NUM_METERS_WIDTH + 120, cy - 40, AI_TYPE_BASIC);
      enemy.AddWeapon(1);
      
      enemy = game.addShip(2, NUM_METERS_WIDTH + 60, cy - 20, AI_TYPE_BASIC_AGGRESSIVE);
      
      enemy = game.addShip(2, NUM_METERS_WIDTH, cy, AI_TYPE_BASIC_AGGRESSIVE);
      enemy.AddWeapon(1);
      
      enemy = game.addShip(2, NUM_METERS_WIDTH + 60, cy + 20, AI_TYPE_BASIC_AGGRESSIVE);
      
      enemy = game.addShip(2, NUM_METERS_WIDTH + 120, cy + 40, AI_TYPE_BASIC);
      enemy.AddWeapon(1);
      break;
    default:
      debugPrint("Error! Invalid formation!");
      break;
  }
}
