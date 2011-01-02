'  ##############
' # test28.bas #
'##############
' short test for 
' fbs_PauseRewindSound()

#libpath "../lib"
#include "../inc/fbsound.bi"

sub fbs_PauseRewindSound(hSound as integer)
  dim as short ptr pStart
  ' stop playback
  fbs_Set_SoundPaused(hSound,True)
  ' get start position
  fbs_Get_SoundPointers(hSound,@pStart)
  ' set it as current play postion
  fbs_Set_SoundPointers(hSound,,pStart)
end sub

const plug_path = "../lib/"
const data_path = "../data/"
fbs_Set_PlugPath(plug_path)
dim as integer   hWave,hSound
fbs_Init()
print "please wait while decode 'legends.ogg' in memory!"
fbs_Load_OGGFile(data_path & "legends.ogg",@hWave)
fbs_Create_Sound(hWave,@hSound)
fbs_Play_Sound(hSound)
print "playing for 5 seconds"
sleep 5000
print "restart sound"
' pause and rewind
fbs_PauseRewindSound(hSound)
' restart the sound
fbs_Set_SoundPaused(hSound,False)
sleep

