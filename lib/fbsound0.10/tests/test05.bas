'  ##############
' # test05.bas #
'##############
' example of:
' fbs_Create_Wave(nSamples,@hWAve,@lpSamples)

#libpath "../lib"
#include "../inc/fbsound.bi"

const plug_path = "../lib/"
const data_path = "../data/"

' only if not same as exe path
fbs_Set_PlugPath(plug_path)

dim as integer         hWave,hSound
dim as single          w,wstep=pi2/44100.0*100
dim as FBS_SAMPLE ptr  lpSamples

fbs_Init()
fbs_Create_Wave(44100,@hWave,@lpSamples)
for i as integer=0 to 44100*2-1
  lpSamples[i]=sin(w)*1000:w+=wstep
next
fbs_Create_Sound(hWave,@hSound)
fbs_Play_Sound(hSound,-1) ' loop endless
? "playing cleean sin wave for 2 seconds"
sleep 2000

? "now changing volume [esc]=quit"
wstep=0
while inkey<>chr(27)
  w=cos(wstep)*0.4+0.5:wstep+=0.01
  locate 3,1: ? "volume=" & w
  fbs_Set_SoundVolume(hSound,w)
  sleep 10
wend
fbs_Get_SoundVolume(hSound,@w)
if w>0.1 then
  ? "fade out and exit"
  while w>0.05
    w*=0.99
    fbs_Set_SoundVolume(hSound,w)
    sleep 10
  wend
endif

end


