# https://stackoverflow.com/questions/28110536/how-to-split-an-mbox-file-into-n-mb-big-chunks-using-the-terminal

BEGIN {

  # Customize this
  maxSizeMB=100;

  fileCount=0;
  currentSize=0;
  maxSize=maxSizeMB * 1024 * 1024;

}

/^From / {
  filename="mail_" sprintf("%03d",fileCount) ".mbox";
  if(currentSize>=maxSize){
    close(filename);
    print "Saved ", filename, "SIZE ", currentSize ;    
    currentSize=0;
    fileCount++;
  }
}

# APPEND EVERY LINE
{
  currentSize+=length();
  print >> filename
}
