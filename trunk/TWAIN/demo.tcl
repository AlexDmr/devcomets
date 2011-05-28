 #---------------
 # Tcl_EZTWAIN.tcl
 #---------------
 # William J Giddings, 2006
 #
 # Convert required functions in EZTW32.dll into Tcl proceedures using Ffidl
 #
 # EZTW32.DLL  http://www.dosadi.com/eztwain1.htm
 # ffidl.dll   http://rutherglen.ics.mq.edu.au/~steffen/tcltk/ffidl/doc/

 load ffidl05.dll

 #---------------
 # Basic Calls
 #---------------
 ffidl::callout EZ_TWAIN_AcquireToFilename {long pointer-utf8 } int [ffidl::symbol EZTW32.dll   TWAIN_AcquireToFilename]

 #---------------
 # select source and pre-scan and acquire to file
 #---------------
  EZ_TWAIN_AcquireToFilename 0 Demo.bmp
