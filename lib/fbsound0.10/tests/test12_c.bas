'  ################
' # test12_c.bas #
'################

' same as "test12.bas" but with ogg loader too

' example of:

' fbs_Set_PlugPath()
' fbs_Init()

' fbs_Load_WAV()
' fbs_Play_Wave()
' fbs_Get_PlayingSounds()
' fbs_Destroy_Wave()

' fbs_Create_MP3Stream()
' fbs_Play_MP3Stream()
' fbs_Get_PlayingStreams()
' fbs_End_MP3Stream()

' fbs_Load_OGGFile()

' scan the whole data folder for wav and mp3 files 
' and play it as short preview

#libpath "../lib"
#include "../inc/fbsound.bi"

const plug_path = "../lib/"
const data_path = "../data/"

' only if not same as exe path
fbs_Set_PlugPath(plug_path)

dim   as integer nfiles,i,hWave,hStream,nSeconds
redim as string  files()
dim   as string  file,key

' and get all *.ogg files
file=dir(data_path & "*.ogg")
while len(file)
  redim preserve files(nFiles)
  files(nFiles)=data_path & file
  nFiles+=1
  file=dir()
wend

' get all *.mp3 files
file=dir(data_path & "*.mp3")
while len(file)
  redim preserve files(nFiles)
  files(nFiles)=data_path & file
  nFiles+=1
  file=dir()
wend

' and get all *.wav files
file=dir(data_path & "*.wav")
while len(file)
  redim preserve files(nFiles)
  files(nFiles)=data_path & file
  nFiles+=1
  file=dir()
wend

if nFiles<1 then
  ? "No *.mp3 or *.wav or *.ogg files in the folder!"
  beep:sleep:end 1
end if


dim as FBSBOOLEAN ok
ok=fbs_Init()
if ok=false then
  ? "error: fbs_Init() !"
  ? fbs_Get_PlugError()
  beep:sleep:end 1
end if

for i=0 to nFiles-1
  hWave=-1
    
  if right(lcase(files(i)),4)=".wav" then 
    ? "loading " & files(i)
    ok=fbs_Load_WAVFile(files(i),@hWave)
    if ok=true then
      ok=fbs_Play_Wave(hWave)
      if ok=true then
        while fbs_Get_PlayingSounds()=0:sleep 10:wend
      end if
    end if
  elseif right(lcase(files(i)),4)=".ogg" then 
    ? "loading " & files(i)
    ok=fbs_Load_OGGFile(files(i),@hWave)
    if ok=true then
      ok=fbs_Play_Wave(hWave)
      if ok=true then
        while fbs_Get_PlayingSounds()=0:sleep 10:wend
      end if
    end if
  elseif right(lcase(files(i)),4)=".mp3" then
    ? "straeming " & files(i) 
    ok=fbs_Create_MP3Stream(files(i))
    if ok=true then
      ok=fbs_Play_MP3Stream()
      if ok=true then 
        hStream=1
        while fbs_Get_PlayingStreams()=0:sleep 10:wend
      end if
    end if
  end if

  if ok=true then
     nSeconds=30 ' 30 * 0.1 = 3 seconds
    ? "wait while preview playing 3 seconds file " & Str(i+1) & " from " & Str(nFiles) & " files."
    Do
      Key=Inkey()
      Sleep 100
      nSeconds-=1
      ? "*";
    Loop While (fbs_Get_PlayingSounds()>0 or fbs_Get_PlayingStreams()<>0) and (nSeconds>0) and (Key<>Chr(27))
    ?
    ' what was it wave or stream
    if (hWave<>-1) then
      fbs_Destroy_Wave(@hWave)
    else
      fbs_End_MP3Stream()
    end if
  end if
  sleep 100
  if Key=chr(27) then exit for
next
end
