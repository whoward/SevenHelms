'  #############
' # test4.bas #
'#############

' example of:
' fbs_Set_PlugPath()
' fbs_Init()
' fbs_Load_MP3file()
' fbs_Play_Wave()
' fbs_Get_PlayTime()
' fbs_Get_PlayedSamples()
' fbs_Get_PlayedBytes()

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
  ? FBS_Get_PlugError()
  beep:sleep:end 1
end if

dim as integer hWave
ok=fbs_Load_MP3File(data_path & "rnb_loop.mp3",@hWave)
if ok=false then
  ? "erro: fbs_LoadMP3File() !"
  beep:sleep:end 1
end if

? "[s]  = togle printing status on/off"
? "[p]  = play it again or parallel"
? "[esc]= quit"
ok=fbs_PLay_Wave(hWave,16) ' loop 16 times
if ok=false then
  ? "error: fbs_Play_Wave() !"
  beep:sleep:end 1
end if

'
' main loop
'
dim as FBSBOOLEAN Status
dim as INTEGER KeyCode
while (KeyCode<>27)
  KeyCode=asc(Inkey) 
	if KeyCode=asc("s") then
	  Status xor=True ' togle printing on/off
	elseif KeyCode=asc("p") then 
	  fbs_PLay_Wave hWave,16
  end if
  if Status=True then
    locate 5,1
    ? "playtime in sec. =" & str(fbs_Get_PlayTime())
    ? "played samples   =" & str(fbs_Get_PlayedSamples())
    ? "played bytes     =" & str(fbs_Get_PlayedBytes())
	else
	  sleep 100	
  end if
wend
end
