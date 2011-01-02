'  ##############
' # test17.bas #
'##############

' Example for user defined STREAM callbacks:

' MASTER callback are in "test15.bas"
' SOUND  callback are in "test16.bas"

' fbs_Set_StreamCallback
' fbs_Enable_StreamCallback
' fbs_Disable_StreamCallback

' In this example i use the StreamBuffer callback
' It is the Buffer with samples before the mixer pipeline

' This is a very simple delay line and only an "how to" use callbacks.
' Better and advanced sound FXs are in the DSP section of FBSOUND.

' All callbacks in FBSOUND are from type BUFFERCALLBACK defined in "fbstypes.bi"

#libpath "../lib"
#include "../inc/fbsound.bi"

const plug_path = "../lib/"
const data_path = "../data/"

' only if not same as exe path
fbs_Set_PlugPath(plug_path)

' shared = readable from inside of the callback
dim shared as FBSBOOLEAN Delay
dim shared as integer    LastIndex
redim shared as FBS_SAMPLE DelayBuffer()
#define DelayTime 0.5 ' how long are the delay in seconds

' !!! gfx screen must be on !!!
sub MyCallback(byval lpSamples  as FBS_SAMPLE ptr, _
               byval nChannels  as integer, _
               byval nSamples   as integer)
  static as integer IndexRead,IndexWrite,Counter
  dim    as integer IndexIn,x,max_x,InSample,OutSample,OldSample

  if Delay=True then
    for x=0 to nSamples-1
      IndexRead=IndexWrite+nChannels
      if IndexRead>=LastIndex then IndexRead=0
      InSample =cint(lpSamples  [IndexIn  ])
      OldSample=cint(DelayBuffer(IndexRead))
      OutSample=InSample+OldSample
      if (OutSample>32767) then
        lpSamples[IndexIn]=32767
      elseif (OutSample<-32768) then
        lpSamples[IndexIn]=-32768
      else
        lpSamples[IndexIn]=cshort(OutSample)
      end if
      InSample =InSample                      shr 1
      OldSample=cint(DelayBuffer(IndexWrite)) shr 1
      OldSample+=InSample
      DelayBuffer(IndexWrite)=OldSample

      if nChannels=2 then
        InSample =cint(lpSamples  [IndexIn  +1])
        OldSample=cint(DelayBuffer(IndexRead+1))
        OutSample=InSample+OldSample
        if (OutSample>32767) then
          lpSamples[IndexIn+1]=32767
        elseif (OutSample<-32768) then
          lpSamples[IndexIn+1]=-32768
        else
          lpSamples[IndexIn+1]=cshort(OutSample)
        end if
        InSample =InSample                        shr 1
        OldSample=cint(DelayBuffer(IndexWrite+1)) shr 1
        OldSample+=InSample
        DelayBuffer(IndexWrite+1)=OldSample
      end if
      ' move one or two Samples
      IndexIn   +=nChannels
      IndexWrite+=nChannels
      if IndexWrite>=LastIndex then IndexWrite=0
    next
  end if
  ' plot only every second buffer
  if (counter and 1)=0 then
    ' shorter as the curent window?
    if nSamples<512 then 
      max_x=nSamples-1
    else
      max_x=511
    end if
    cls
    IndexIn=0
    for x=0 to max_x
      OutSample=(lpSamples[IndexIn] shr 8)
      line (x,32+OutSample)-(x,32-OutSample),2
      IndexIn+=nChannels
    next
    line (max_x,32)-(0,32),15
    if nChannels=2 then
      IndexIn=1
      for x=0 to max_x
        OutSample=(lpSamples[IndexIn] shr 8)
        line (x,96+OutSample)-(x,96-OutSample),4
        IndexIn+=nChannels
      next
      line (max_x,96)-(0,96),15
    end if
  end if
  counter+=1
end sub

'
' main
'
dim as integer hWave,hSound,KeyCode,index,nFrames
dim as FBSBOOLEAN ok,Callback

ok=fbs_Init(22050)
if ok=false then
  ? "error: fbs_Init() !"
  beep:sleep:end 1
else
  ' how many Samples fore one seconds * DelayTime
  LastIndex =fbs_Get_PlugRate()*DelayTime
  LastIndex*=fbs_Get_PlugChannels() ' DelayTime*Channels
  ' how many samples in 0 based DelayBuffer
  LastIndex-=1
  redim DelayBuffer(LastIndex)
end if

fbs_Create_MP3Stream(data_path & "legends.mp3")
fbs_Set_StreamCallback(@MyCallback)
fbs_Play_MP3Stream()

screenres 512,128
windowtitle "[esc]=quit [c]=callback on/off [d]=dealay on/off"

' screen must be on for the callback
ok=fbs_Enable_StreamCallback()
callback=true
' wait on first sample
while fbs_Get_PlayingStreams()=0:sleep 10:wend

'
' main loop
'
while (KeyCode<>27) and (fbs_Get_PlayingStreams>0)
  KeyCode=asc(inkey)
  if KeyCode=asc("c") then
    Callback xor=True ' togle callback on/off
    if Callback=false then 
      fbs_Disable_StreamCallback()
    else
      fbs_Enable_StreamCallback()
    end if
    windowtitle "[esc]=quit [c]=" & str(Callback) & " [d]=" & str(Delay)
  elseif KeyCode=asc("d") then
    Delay xor=True ' togle Delay on/off
    windowtitle "[esc]=quit [c]=" & str(Callback) & " [d]=" & str(Delay)
  elseif (KeyCode=27) then
    fbs_Disable_StreamCallback()
  end if
  sleep 100 ' time for windowtitle and keyboards events
wend
end
