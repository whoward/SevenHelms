'  ##############
' # test12.bas #
'##############

' example of: 
' fbs_Dstroy_Wave(@hWave)
' take look in "test12_b.bas" for streaming

' scan the whole data folder for wav and mp3 files 
' and play it as short preview

#libpath "../lib"
#include "../inc/fbsound.bi"

const plug_path = "../lib/"
const data_path = "../data/"

' only if not same as exe path
fbs_Set_PlugPath(plug_path)

dim   as integer nfiles,i,hWave,nSeconds
redim as string  files()
dim   as string  file,key

' get all *.mp3
File=dir(data_path & "*.mp3")
while len(file)
  redim preserve Files(nFiles)
  Files(nFiles)=data_path & File
  nFiles+=1
  File=dir()
wend

' and get all *.wav too
File=dir(data_path & "*.wav")
while len(file)
  redim preserve Files(nFiles)
  Files(nFiles)=data_path & File
  nFiles+=1
  File=dir()
wend

if nFiles<1 then
  ? "No *.mp3 or *.wav files in curent folder!"
  beep:sleep:end 1
end if

dim as FBSBOOLEAN ok
ok=fbs_Init()
if ok=false then
  ? "error: fbs_Init() !"
  ? fbs_get_plugerror()
  beep:sleep:end 1
end if

for i=0 to nFiles-1
  ? "loading " & files(i)
  if instr(files(i),".mp3") then 
    ok=fbs_Load_MP3File(files(i),@hWave)
  elseif instr(files(i),".wav") then 
    ok=fbs_Load_WAVFile(files(i),@hWave)
  end if

  if ok=true then
    ok=fbs_Play_Wave(hWave)
    if ok=true then
      nSeconds=30 ' 30 * 0.1 = 3 seconds
      ? "wait while preview playing 3 seconds file " & Str(i+1) & " from " & Str(nFiles) & " files."
      Do
        Key=Inkey()
        Sleep 100
        nSeconds-=1
        ? "*";
      Loop While (fbs_Get_PlayingSounds()>0) and (nSeconds>0) and (Key<>Chr(27))
      ?
    end if  
    ' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ' dont' add more and more files in the pool of waves
    ' !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if fbs_Destroy_Wave(@hWave)=false then
      ? "error: can't destroy hWave"
    end if
  end if
  sleep 100
  if Key=chr(27) then exit for
next
end
