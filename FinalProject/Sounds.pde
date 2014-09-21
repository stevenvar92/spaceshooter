// Sounds
Minim minim;
AudioPlayer music;
AudioPlayer sfx;

void InitSounds()
{
  minim = new Minim(this);
  UpdateMusic();
}

// Updates Music based on game context
void UpdateMusic()
{
  switch(game_state)
  {
    case GAME_STATE_MAIN_MENU:
      PlayMusic("mainmenu.mp3", true);
      break;
    case GAME_STATE_RUNNING:
      PlayMusic("maingame.mp3", true);
      break;
    default:
      debugPrint("Error! Invalid game state. (UpdateMusic())");
      break;
  }
}

AudioPlayer Custom_LoadMusic(String filename)
{ 
  return minim.loadFile("./Sounds/Music/" + filename);
}

AudioPlayer Custom_LoadSFX(String filename)
{ 
  return minim.loadFile("./Sounds/SFX/" + filename);
}

void PlayMusic(String filename, boolean bLoop)
{    
  if(music != null && music.isPlaying())
    music.close();
    
  music = Custom_LoadMusic(filename);
 
  music.play(0);
  
  if(bLoop)
    music.loop();
}

void PlaySound(String filename)
{
  sfx = Custom_LoadSFX(filename);
  if(sfx == null)
    println("Could not load SFX " + filename);
  sfx.play(0);
}
