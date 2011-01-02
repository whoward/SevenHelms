'  ##############
' # test20.bas #
'##############

' Example: for user defined buffer callbacks:

' fbs_PichShift()
' fbs_Set_MasterCallback()
' fbs_Enable_MasterCallback()
' fbs_Disable_MasterCallback()
' fbs_Get_StreamVolume()
' fbs_Set_StreamVolume()

' In this example i use the master callback again
' It is the Buffer with samples after the mixer pipeline

' This is an time indepented pitch shifter from -1 octave to +1 octave

#libpath "../lib"
#include "../inc/fbsound.bi"
const plug_path = "../lib/"
const data_path = "../data/"
' only if not same as exe path
fbs_Set_PlugPath(plug_path)

' shared = readable from inside of the callback
dim shared as single v=1

sub MyCallback(byval lpSamples  as FBS_SAMPLE ptr, _
               byval nChannels  as integer, _
               byval nSamples   as integer)
  fbs_PitchShift(lpSamples,lpSamples,v,nSamples)
end sub

'
' main
'
dim as FBSBOOLEAN blnExit,blnFadeOut
dim as integer KeyCode,note,oldloops,loops,hWave,hSound
dim as single  MainVolume
dim as string  Key

fbs_Init()
fbs_Load_MP3File(data_path & "010.mp3",@hWave)
fbs_Create_Sound(hWave,@hSound)
fbs_Get_MasterVolume(@MainVolume)
fbs_Set_MasterCallback(@MyCallback)
note=-7
v=fbs_pow(2,note*(1.0/12.0))
fbs_Enable_MasterCallback()
fbs_play_Sound(hSound,25)

'
' main loop
'
? "[esc]=quit Time independent frequency shift!"
while (blnExit=False)
  Key=inkey
  if (Key=chr(27)) and (blnFadeOut=false) then
    blnFadeOut=True
    ? "fade out and quit"
  end if
  if (blnFadeOut=true) then
    fbs_Get_MasterVolume(@MainVolume)
    if (MainVolume>0.0) then
      MainVolume-=0.01:fbs_Set_MasterVolume(MainVolume)
    else
      blnExit=True
    end if
  end if
  fbs_get_SoundLoops(hSound,@loops)
  if (loops<>oldloops) and (blnFadeOut=false) then
    note+=1
    v=fbs_pow(2,note*(1.0/12.0))
    ? "key on piano relative to the original:" & str(note),v
    oldloops=loops
    if note>=8 then 
      blnFadeOut=true
      ? "fade out and quit"
    end if
  end if
  sleep 50
wend
end
