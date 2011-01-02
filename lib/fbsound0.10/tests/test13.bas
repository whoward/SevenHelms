'  ##############
' # test13.bas #
'##############

' example for:
' fbs_Init() with an second playback device

' ok=fbs_Init([nRate],[nChannels],[nBuffers],[nFrames],[index])
' it will use an second playback device if any aviable
' index=0 first device
' index=1 second device
' ...

#libpath "../lib"
#include "../inc/fbsound.bi"

const plug_path = "../lib/"
const data_path = "../data/"

' only if not same as exe path
fbs_Set_PlugPath(plug_path)

dim as FBSBOOLEAN ok
ok=fbs_Init(,,,,5)
if ok=false then
  ? "No second device for playback !"
  ? "fall back to first device (default)"
  ok=fbs_Init()
  if ok=false then
    ? "No playback device aviable!"
    ? fbs_get_PlugError()
    beep:sleep:end 1
  else
    ? "playback with first device!"
  end if
else
  ? "playback with second device."
end if

'
' main
'
fbs_Create_MP3Stream(data_path & "fox.mp3")
fbs_Play_MP3Stream()
while fbs_Get_PlayingStreams()=0:sleep 10:wend

? "wait on end of stream or press any key."
while (len(inkey)=0) and (fbs_Get_PlayingStreams()>0)
  sleep 100 
wend
end

