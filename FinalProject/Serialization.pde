// Why do we need a game again...? Check that.
void SaveGame(Game game)
{
  if(game == null) return;
  
  println("Serializing...");
  
  if(getMyDocumentsString() == null)
  {
    println("Error! My Documents not found, serialization failed!");
    return;
  }
  
  try
  {
    FileOutputStream fileOut = new FileOutputStream(getMyDocumentsString() + "/game_design_project_saves.ser");
    ObjectOutputStream out = new ObjectOutputStream(fileOut);
    out.writeObject(profile);
    out.close();
    fileOut.close();
  }
  catch(IOException i)
  {
    i.printStackTrace();
  }
  
  println("Serialization complete.");
}

// Profile data loaded in on application enter
static void LoadProfileData(Profile prof)
{
  // the whole serialization thing is fucked...whatever
  // so we save stuff but can't load it. Fantastic
  // we can't cast to "Profile" class for some stupid reason.
  /*
  try
  {
    FileInputStream fileIn = new FileInputStream(getMyDocumentsString() + "game_design_project_saves.ser");
    ObjectInputStream in = new ObjectInputStream(fileIn);
    prof = (Profile) in.readObject();
    in.close();
    fileIn.close();
  }
  catch(IOException i)
  {
    println("File not found. Load aborted.");
    return;
  }
  
  println("Profile loaded. Hello TEST");
  */
}

// Returns the filepath of MyDocuments. Will fail if not on windows
String getMyDocumentsString()
{
  String myDocuments = null;

  try {
      Process p =  Runtime.getRuntime().exec("reg query \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders\" /v personal");
      p.waitFor();
  
      InputStream in = p.getInputStream();
      byte[] b = new byte[in.available()];
      in.read(b);
      in.close();
  
      myDocuments = new String(b);
      myDocuments = myDocuments.split("\\s\\s+")[4];
  
  } catch(Throwable t) {
      t.printStackTrace();
  }
  
  return myDocuments;
}
