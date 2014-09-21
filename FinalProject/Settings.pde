static final boolean debug = false;

// COLORS
static final color COLOR_GREY          = #808080;
static final color COLOR_LIGHT_GREEN   = #90EE90;
static final color COLOR_XP            = #00BFFF;
static final color COLOR_SHIELD        = #0099CC;
static final color COLOR_HEALTH        = #00CC00;
static final color COLOR_BEIGE         = #F5F5DC;
static final color COLOR_WHITE         = #FFFFFF;

static final int GAME_STATE_MAIN_MENU = 0,
                 GAME_STATE_RUNNING = 1,
                 GAME_STATE_LOADOUT = 2,
                 GAME_STATE_OPTION = 3;

// WINDOW RESOLUTIONS
// Goal is to have these modifyable through an Options Menu
// When this happens, we'll need an Application/Game object to store information. Anything that relies on screen width/height will need to use that.
// For the purposes of this demo, hardcoding the values are acceptable

// 4:3
  // 800 x 600
  // 1024 x 768
  // 1400 x 1050
  
// 16:9
  // 1280 x 720
  // 1600 x 900

// 16:10
  // 1280x800
  // 1440x900
  // 1680x1050
