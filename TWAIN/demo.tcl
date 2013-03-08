 #---------------
 # Tcl_EZTWAIN.tcl
 #---------------
 # William J Giddings, 2006
 #
 # Convert required functions in EZTW32.dll into Tcl proceedures using Ffidl
 #
 # EZTW32.DLL  http://www.dosadi.com/eztwain1.htm
 # ffidl.dll   http://rutherglen.ics.mq.edu.au/~steffen/tcltk/ffidl/doc/

 load ffidl06.dll

 # create some global constants:
 set TWAIN_BW      0x0001  ;# 1 bit
 set TWAIN_GRAY    0x0002  ;# 1,4,8 bit grayscale
 set TWAIN_RGB     0x0004  ;# 24-bit rgb
 set TWAIN_PALETTE 0x0008  ;# 1,4 or 8-bit palette
 set TWAIN_ANYTYPE 0x0000  ;# any of the above

 #---------------
 # Basic Calls
 #---------------
 #---------------
 ffidl::callout EZ_TWAIN_AcquireNative {long unsigned} long [ffidl::symbol EZTW32.dll TWAIN_AcquireNative]
 ffidl::callout EZ_TWAIN_FreeNative {long} void [ffidl::symbol EZTW32.dll TWAIN_FreeNative]
 ffidl::callout EZ_TWAIN_AcquireToClipboard {long unsigned} int [ffidl::symbol EZTW32.dll TWAIN_AcquireToClipboard]
 ffidl::callout EZ_TWAIN_AcquireToFilename {long pointer-utf8 } int [ffidl::symbol EZTW32.dll TWAIN_AcquireToFilename]
 ffidl::callout EZ_TWAIN_SelectImageSource {long} int [ffidl::symbol EZTW32.dll TWAIN_SelectImageSource]

 #---------------
 # Basic TWAIN Inquiries
 #---------------
 ffidl::callout EZ_TWAIN_IsAvailable {} int [ffidl::symbol EZTW32.dll TWAIN_IsAvailable]
 ffidl::callout EZ_TWAIN_EasyVersion {} int [ffidl::symbol EZTW32.dll TWAIN_EasyVersion]
 ffidl::callout EZ_TWAIN_State {} long [ffidl::symbol EZTW32.dll TWAIN_State]

 #---------------
 # DIB Handling Utilities
 #---------------
 ffidl::callout EZ_TWAIN_DibDepth {long} int [ffidl::symbol EZTW32.dll TWAIN_DibDepth]
 ffidl::callout EZ_TWAIN_DibWidth {long} int [ffidl::symbol EZTW32.dll TWAIN_DibWidth]
 ffidl::callout EZ_TWAIN_DibHeight {long} int [ffidl::symbol EZTW32.dll TWAIN_DibHeight]
 ffidl::callout EZ_TWAIN_DibNumColors {long} int [ffidl::symbol EZTW32.dll TWAIN_DibNumColors]

 # The Header declares TWAIN_RowSize, but EZ_TWAIN.C has TWAIN_RowBytes, but EZTW32.dll has neither!
 # ffidl::callout EZ_TWAIN_RowSize {long} int [ffidl::symbol EZTW32.dll TWAIN_RowSize]
 # ffidl::callout EZ_TWAIN_ReadRow {long int long} void [ffidl::symbol EZTW32.dll TWAIN_ReadRow]

 ffidl::callout EZ_TWAIN_DrawDibToDC {long int int int int long int int} void [ffidl::symbol EZTW32.dll TWAIN_DrawDibToDC]

 #---------------
 # BMP File Utilities
 #---------------
 ffidl::callout EZ_TWAIN_WriteNativeToFileName {long pointer-utf8} int [ffidl::symbol EZTW32.dll TWAIN_WriteNativeToFilename]
 ffidl::callout EZ_TWAIN_WriteNativeToFile {long long} long [ffidl::symbol EZTW32.dll TWAIN_WriteNativeToFile]
 ffidl::callout EZ_TWAIN_LoadNativeFromFilename {pointer-utf8} long [ffidl::symbol EZTW32.dll TWAIN_LoadNativeFromFilename]

 #---------------
 # UI Display Settings
 #---------------
 ffidl::callout EZ_TWAIN_SetHideUI {int} void [ffidl::symbol EZTW32.dll TWAIN_SetHideUI]
 ffidl::callout EZ_TWAIN_GetHIdeUI {} int [ffidl::symbol EZTW32.dll TWAIN_GetHideUI]

 #---------------
 # Application Registration
 #---------------
 ffidl::callout EZ_TWAIN_RegisterApp {int int int int pointer-utf8 pointer-utf8 pointer-utf8 pointer-utf8} void [ffidl::symbol EZTW32.dll TWAIN_RegisterApp]

 #---------------
 # Error Analysis and Reporting
 #---------------
 ffidl::callout EZ_TWAIN_GetResultCode {} unsigned [ffidl::symbol EZTW32.dll TWAIN_GetResultCode]
 ffidl::callout EZ_TWAIN_GetConditionCode {} unsigned [ffidl::symbol EZTW32.dll TWAIN_GetConditionCode]
 ffidl::callout EZ_TWAIN_ErrorBox {pointer-utf8} void [ffidl::symbol EZTW32.dll TWAIN_ErrorBox]
 ffidl::callout EZ_TWAIN_ReportLastError {pointer-utf8} void [ffidl::symbol EZTW32.dll TWAIN_ReportLastError]

 #---------------
 # TWAIN State Control
 #---------------
 ffidl::callout EZ_TWAIN_LoadSourceManager {} int [ffidl::symbol EZTW32.dll TWAIN_LoadSourceManager]
 ffidl::callout EZ_TWAIN_OpenSourceManager {long} int [ffidl::symbol EZTW32.dll TWAIN_OpenSourceManager]
 ffidl::callout EZ_TWAIN_OpenDefaultSource {} int [ffidl::symbol EZTW32.dll TWAIN_OpenDefaultSource]
 ffidl::callout EZ_TWAIN_EnableSource {long} int [ffidl::symbol EZTW32.dll TWAIN_EnableSource]
 ffidl::callout EZ_TWAIN_DisableSource {} int [ffidl::symbol EZTW32.dll TWAIN_DisableSource]
 ffidl::callout EZ_TWAIN_CloseSource {} int [ffidl::symbol EZTW32.dll TWAIN_CloseSource]
 ffidl::callout EZ_TWAIN_CloseSourceManager {long} int [ffidl::symbol EZTW32.dll TWAIN_CloseSourceManager]
 ffidl::callout EZ_TWAIN_UnloadSourceManager {} int [ffidl::symbol EZTW32.dll TWAIN_UnloadSourceManager]
 ffidl::callout EZ_TWAIN_MessageHook {long} int [ffidl::symbol EZTW32.dll TWAIN_MessageHook]
 ffidl::callout EZ_TWAIN_ModalEventLoop {} void [ffidl::symbol EZTW32.dll TWAIN_ModalEventLoop]
 ffidl::callout EZ_TWAIN_EndXfer {} int [ffidl::symbol EZTW32.dll TWAIN_EndXfer]
 ffidl::callout EZ_TWAIN_AbortAllPendingXfers {} int [ffidl::symbol EZTW32.dll TWAIN_AbortAllPendingXfers]
 if {[catch {ffidl::callout EZ_TWAIN_WriteDibToFile {long long} long [ffidl::symbol EZTW32.dll TWAIN_WriteDibToFile]} err]} {puts stderr $err}

 #---------------
 # High-Level Capability Negotiation Functions
 #---------------
 ffidl::callout EZ_TWAIN_NegotiateXferCount {int} int [ffidl::symbol EZTW32.dll TWAIN_NegotiateXferCount]
 ffidl::callout EZ_TWAIN_NegotiatePixelTypes {unsigned} int [ffidl::symbol EZTW32.dll TWAIN_NegotiatePixelTypes]
 ffidl::callout EZ_TWAIN_SetCurrentUnits {int} int [ffidl::symbol EZTW32.dll TWAIN_SetCurrentUnits]
 ffidl::callout EZ_TWAIN_GetCurrentUnits {} int [ffidl::symbol EZTW32.dll TWAIN_GetCurrentUnits]
 ffidl::callout EZ_TWAIN_GetBitDepth {} int [ffidl::symbol EZTW32.dll TWAIN_GetBitDepth]
 ffidl::callout EZ_TWAIN_SetBitDepth {int} int [ffidl::symbol EZTW32.dll TWAIN_SetBitDepth]
 ffidl::callout EZ_TWAIN_GetPixelType {} int [ffidl::symbol EZTW32.dll TWAIN_GetPixelType]
 ffidl::callout EZ_TWAIN_SetCurrenPixelType {int} int [ffidl::symbol EZTW32.dll TWAIN_SetCurrentPixelType]
 ffidl::callout EZ_TWAIN_GetCurrentResolution {} double [ffidl::symbol EZTW32.dll TWAIN_GetCurrentResolution]
 ffidl::callout EZ_TWAIN_GetYResolution {} double [ffidl::symbol EZTW32.dll TWAIN_GetYResolution]
 ffidl::callout EZ_TWAIN_SetCurrentResolution {double} int [ffidl::symbol EZTW32.dll TWAIN_SetCurrentResolution]
 ffidl::callout EZ_TWAIN_SetContrast {double} int [ffidl::symbol EZTW32.dll TWAIN_SetContrast]
 ffidl::callout EZ_TWAIN_SetBrightness {double} int [ffidl::symbol EZTW32.dll TWAIN_SetBrightness]
 ffidl::callout EZ_TWAIN_SetXferMech {int} int [ffidl::symbol EZTW32.dll TWAIN_SetXferMech]
 ffidl::callout EZ_TWAIN_XferMEch {} void [ffidl::symbol EZTW32.dll TWAIN_XferMech]

 #---------------
 # Low-Level Capability Negotiation Functions
 #---------------
 # Setting a capability is valid only in State 4 (TWAIN_SOURCE_OPEN)
 # Getting a capability is valis in a State 4 or higher state.
 ffidl::callout EZ_TWAIN_SetCapOneValue {unsigned unsigned long} int [ffidl::symbol EZTW32.dll TWAIN_SetCapOneValue]
 ffidl::callout EZ_TWAIN_GetCapCurrent {unsigned unsigned long} int [ffidl::symbol EZTW32.dll TWAIN_GetCapCurrent]
 ffidl::callout EZ_TWAIN_ToFix32 {double} int [ffidl::symbol EZTW32.dll TWAIN_ToFix32]
 ffidl::callout EZ_TWAIN_Fix32ToFloat {long} int [ffidl::symbol EZTW32.dll TWAIN_Fix32ToFloat]
 ffidl::callout EZ_TWAIN_DS {long unsigned unsigned long} int [ffidl::symbol EZTW32.dll TWAIN_DS]
 ffidl::callout EZ_TWAIN_Mgr {long unsigned unsigned long} int [ffidl::symbol EZTW32.dll TWAIN_Mgr]

 #---------------
 # select source and pre-scan and acquire to file
 #---------------
  proc EZ_TWAIN_demo1 {} {
  EZ_TWAIN_SelectImageSource 0
  EZ_TWAIN_AcquireToFilename 0 Demo1.bmp
  # exit
 }

 # scan straight to file using previous settings..
 proc EZ_TWAIN_demo2 {} {
  EZ_TWAIN_SetHideUI 1
  EZ_TWAIN_AcquireToFilename 0 Demo2.bmp
  # exit
 }

 # this one scans to a device independent bitmap (DIB), then saves is to file, the puts some settings..
 proc EZ_TWAIN_demo3 {{PageName {}}} {
  if {[EZ_TWAIN_OpenDefaultSource]} {
   EZ_TWAIN_SetHideUI 1
   EZ_TWAIN_SetCurrentUnits 0
   EZ_TWAIN_SetCurrentResolution 300.0
   set hd [EZ_TWAIN_AcquireNative 0 $::TWAIN_BW]
   EZ_TWAIN_WriteNativeToFileName $hd $PageName.bmp

  }
  if {[EZ_TWAIN_OpenDefaultSource]} {
    foreach i {PixelType BitDepth CurrentResolution CurrentUnits} {
      puts [EZ_TWAIN_Get$i ]
    }
  }
}

  # Very basic commands
  puts [list EZ_TWAIN_SelectImageSource 0]
  puts [list EZ_TWAIN_AcquireToFilename 0 Demo.bmp]
