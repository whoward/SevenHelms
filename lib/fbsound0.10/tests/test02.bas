'  #############
' # test2.bas #
'#############

' example of:

' fbs_Set_PlugPath()
' fbs_Init()
' fbs_Get_PlugError()
' fbs_Load_WAVFile()
' fbs_Play_Wave()

#libpath "../lib"
#include "../inc/fbsound.bi"

const plug_path = "../lib/"
const data_path = "../data/"

' only if not same as exe path
fbs_Set_PlugPath(plug_path)

dim as FBSBOOLEAN ok
ok=fbs_Init(48000)
if ok=false then
  ? "error: fbs_Init() !"
  ? FBS_Get_PlugError()
  beep:sleep:end 1
end if

dim as integer hWave
ok=fbs_Load_WAVFile(data_path & "fbsloop44.wav",@hWave)
if ok=false then
  ? "error: fbs_Load_WAVFile() !"
  beep:sleep:end 1
end if

'get next free playback channel or create one
ok=fbs_Play_Wave(hWave)
if ok=false then
  ? "error: fbs_Play_Wave() !"
  beep:sleep:end 1
end if

'
' main loop
'
? "[p]   = begin new playback (4 loops)"
? "[esc] = quit"

dim as integer KeyCode
while KeyCode<>27
  KeyCode=asc(Inkey)
  if KeyCode=asc("p") then
    fbs_Play_Wave hWave,4 ' optional 4 times
  else
    sleep 100
  end if
wend
end
