// Utility functions to assist in graphics representation.

/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
// REALLY IMPORTANT GAMEPLAY CONSTANTS!!!!!!!!!!!!!!!!!
// DANGER DANGER DANGER
// Don't be an idiot and change these values!
// These values are integral to the game core!
static final int NUM_MILLIS_IN_SEC = 1000;                                                        // how many milliseconds in a second?
static final int NUM_UPDATES_PER_SEC = 60;                                                        // how many updates should we run a second?
static final double MS_PER_UPDATE = ((double)NUM_MILLIS_IN_SEC / (double)NUM_UPDATES_PER_SEC);    // how many milliseconds will it take to run another update?
static final int NUM_METERS_WIDTH = 800;                                                          // how many meters is the game screen? (wide)
static final int NUM_METERS_HEIGHT = 600;                                                         // how many meters is the game screen? (tall)
  // what this means:
    // An object traveling at 2000 m/s will leave the game screen in 1 second
    // An object that is 200 meters wide is 10% of the screen width
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////
// GRAPHICS 
// Screen ratios useful for graphics processing only!
float ScreenXRatio() { return (float) width / NUM_METERS_WIDTH; }
float ScreenYRatio() { return (float) height / NUM_METERS_HEIGHT; }

// Function disabled as they are unnecessary and redundant
/*
// How many meters is the width of the screen?
float GetMetersWidth()
{
  // Fixing up horrendous code. Always just return the meters width
  //if(NUM_METERS_WIDTH == 0)
  //  return SCREEN_WIDTH;
  
  return NUM_METERS_WIDTH;
}

// How many meters is the height of the screen?
float GetMetersHeight()
{
  return NUM_METERS_HEIGHT;
  
  float rtn = 0;
  switch( SCREEN_MODE )
  {
    case SCREEN_MODE_4_BY_3:
      rtn = GetMetersWidth() * (0.75f);
      break;
    case SCREEN_MODE_16_BY_9:
      rtn = GetMetersWidth() * (0.5625f);
      break;
    case SCREEN_MODE_16_BY_10:
      rtn = GetMetersWidth() * (0.625f);
      break;
    default:
      // Uh-oh
      print("Invalid screen mode defined. Assuming 4:3.");
      rtn = GetMetersWidth() * (0.75f);
      break;
  }
  
  return rtn;
}
*/

// FOR GRAPHICS PROCESSING
// How much is one pixel?
//float GetWidthPixelsPerMeter()  { return SCREEN_WIDTH  / GetMetersWidth();  }
//float GetHeightPixelsPerMeter() { return SCREEN_HEIGHT / GetMetersHeight(); }

///////////////////////////////////////
// VELOCITY
/*
// Accepts a distance in meters and returns a distance in pixels.
float pixelDistanceX(float dist_meters, boolean bAdjustForPhysicsUpdate) {
  float rtnValue = dist_meters * GetWidthPixelsPerMeter();
  if(bAdjustForPhysicsUpdate)
    rtnValue /= NUM_UPDATES_PER_SEC;
  return rtnValue;
}
float pixelDistanceY(float dist_meters, boolean bAdjustForPhysicsUpdate) {
  float rtnValue = dist_meters * GetHeightPixelsPerMeter();
  if(bAdjustForPhysicsUpdate)
    rtnValue /= NUM_UPDATES_PER_SEC;
  return rtnValue;
}
*/
///////////////////////////////////////
// COLLISION
// does e1 collide with e2?
boolean isCollide(Entity e1, Entity e2)
{  
  if(e1 == null || e2 == null) return false;
  if(!e1.canCollide(e2)) return false;
  
  Rectangle r1 = e1.getCollisionBox();
  Rectangle r2 = e2.getCollisionBox();
  
  if(r1.intersects(r2))
    return true;
    
  return false;
}

// Accepts a time (in ms) and returns a formatted time string in HH:MM:SS format
String GetTimeString(int time_ms)
{
  final int MS_PER_SEC = 1000;
  final int MS_PER_MIN = 60 * MS_PER_SEC;
  final int MS_PER_HR = 60 * MS_PER_MIN;
  
  // First get the raw number...
  Integer hours = time_ms / MS_PER_HR;
  Integer mins = time_ms / MS_PER_MIN;
  Integer secs = time_ms / MS_PER_SEC;
  Integer ms = time_ms;
  
  // Only care about 0-59!
  mins %= 60;
  secs %= 60;
  ms %= 60;
  
  return hours.toString() + ":" + mins.toString() + ":" + secs.toString() + ":" + ms.toString();
}

public void debugPrint(String message)
{
  if(debug)
  {
    println(millis() + ": " + message);
  }
}

// Draw an entity's collision data
public void outline(Rectangle r1)
{
  if(debug)
  {
    noFill();
    stroke(#FFFFFF);
    strokeWeight(1);
    rect((float)r1.getX(),(float)r1.getY(),(float)r1.getWidth(),(float)r1.getHeight());
  }
}

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// A quadtree class useful for collision detection!
// This guy saves you toooonnns of frames!
// Credits to gamedevelopment.tutsplus.com's Steven Lambert for the code
public class Quadtree
{
  private int MAX_OBJECTS = 10;
  private int MAX_LEVELS = 5;
  
  private int level;                    // the level of the tree
  private ArrayList<Entity> objects;    // we insert the objects of the quadtree here
  private Rectangle bounds;             // the bounds of the quadtree (screen dimensions)
  private Quadtree[] nodes;             // the nodes of the quadtree
  
  public Quadtree(int iLevel, Rectangle pBounds)
  {
    level = iLevel;
    objects = new ArrayList<Entity>();
    bounds = pBounds;
    nodes = new Quadtree[4];
  }
  
  // Clear the quadtree
  public void clear()
  {
    objects.clear();
    
    for (int i = 0; i < nodes.length; i++)
    {
      if(nodes[i] != null)
      {
        nodes[i].clear();
        nodes[i] = null;
      }
    }
  }
  
  // Split the node into 4 subnodes
  private void split()
  {
    int subWidth = (int) (bounds.getWidth() / 2);
    int subHeight = (int) (bounds.getHeight() / 2);
    int x = (int) bounds.getX();
    int y = (int) bounds.getY();
    
    nodes[0] = new Quadtree(level+1, new Rectangle(x + subWidth, y, subWidth, subHeight));
    nodes[1] = new Quadtree(level+1, new Rectangle(x, y, subWidth, subHeight));
    nodes[2] = new Quadtree(level+1, new Rectangle(x, y + subHeight, subWidth, subHeight));
    nodes[3] = new Quadtree(level+1, new Rectangle(x + subWidth, y + subHeight, subWidth, subHeight));
  }
  
  // Determine the node the object bleongs to. -1 means object cannot completely fit within a child node and is part of the parent node.
  private int getIndex(Entity obj)
  {
    int index = -1;
    double vertMidPoint = bounds.getX() + (bounds.getWidth() / 2);
    double horizMidPoint = bounds.getY() + (bounds.getHeight() / 2);
    
    boolean topQuadrant = obj.getY() < horizMidPoint && obj.getY() + obj.getSizeY() < horizMidPoint;      // object can completely fit within top quadrants
    boolean bottomQuadrant = obj.getY() > horizMidPoint;                                    // object can completely fit within bottom quadrants
    boolean leftQuadrant = obj.getX() < vertMidPoint && obj.getX() + obj.getSizeX() < vertMidPoint; // object can completely fit within the left quadrants
    boolean rightQuadrant = obj.getX() > vertMidPoint;                                                  // object can completely fit within the right quadrants
    
    if(leftQuadrant)
    {
      if(topQuadrant) index = 1;
      else if(bottomQuadrant) index = 2;
    }
    else if(rightQuadrant)
    {
      if(topQuadrant) index = 0;
      else if(bottomQuadrant) index = 3;
    }
    
    return index;
  }
  
  // Insert the object into quadtree. If the node exceeds capacity, it will split and all objects to their correct nodes.
  public void insert(Entity obj)
  {
    if(nodes[0] != null)
    {
      int index = getIndex(obj);
      if(index != -1)
      {
        nodes[index].insert(obj);
        return;
      }
    }
    
    objects.add(obj);
    
    // Did we exceed the maximum number of objects this node can support? (and can we further subdivide levels?)
    if(objects.size() > MAX_OBJECTS && level < MAX_LEVELS)
    {
      if(nodes[0] == null) split();
      
      int i = 0;
      while(i < objects.size())
      {
        int index = getIndex(objects.get(i));
        if(index != -1) nodes[index].insert(objects.remove(i));
        else i++;
      }
    }
  }
  
  // Return all objects that could collide with the given object
  public ArrayList<Entity> retrieve(ArrayList<Entity> returnObjects, Entity obj)
  {
    int index = getIndex(obj);
    if(index != -1 && nodes[0] != null)
    {
      nodes[index].retrieve(returnObjects, obj);
    }
    
    returnObjects.addAll(objects);
    
    return returnObjects;
  }
  
  public void draw()
  {    
    if(nodes[0] != null) nodes[0].draw();
    if(nodes[1] != null) nodes[1].draw();
    if(nodes[2] != null) nodes[2].draw();
    if(nodes[3] != null) nodes[3].draw();
    
    outline(bounds);
  }
}

PImage Custom_LoadImage(String filename) { return loadImage("./Images/" + filename); }
PFont Custom_LoadFont(String filename) { return loadFont("./Fonts/" + filename); }
