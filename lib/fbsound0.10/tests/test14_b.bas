'  ################
' # test14_b.bas #
'################
' same as "test14.bas" but with MP3 streaming
' simple speed test
' streaming decoding and resampling MP3.

#libpath "../lib"
#include "../inc/fbsound.bi"

const plug_path = "../lib/"
const data_path = "../data/"

' only if not same as exe path
fbs_Set_PlugPath(plug_path)

dim as FBSBOOLEAN ok
ok=fbs_Init()
if ok=false then
  ? "error: fbs_Init() !"
  beep:sleep:end 1
end if

? "any key = quit"
while inkey=""
  ? "create stream: ";
  fbs_Create_MP3Stream(data_path & "atem.mp3")
  ? "ok"
  ? "wait on start: ";
  fbs_Play_MP3Stream
  while fbs_Get_PlayingStreams()=0:sleep 10:wend
  ? "ok"
  ? "wait on end  : ";
  while fbs_Get_PlayingStreams()>0:sleep 10:wend
  ? "ok":?
  sleep 100
wend 
end


