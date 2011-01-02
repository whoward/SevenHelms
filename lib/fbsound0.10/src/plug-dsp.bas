'  ##################
' # plug-dsp.bas #
'##################
#include "plug.bi"
#include "plug-dsp.bi"

type DSP
  as FBS_PLUG     Plug
  as FILEHANDLE   hDevice
  as zstring * 128       LastError
end type

dim shared _Me as DSP

sub _init() constructor
  dprint("dsp:_init")
  _Me.Plug.Plugname="DSP"
end sub

sub _exit() constructor
  dprint("dsp:_exit")
  _Me.Plug.Plugname="DSP"
end sub

private _
function DSPWrite() as integer
  dim as integer ret,Buffersize,nErrors
  dim as any ptr lpBuffer
  ' that should never hapent
  if _Me.hDevice             =    0 then return 0
  if _Me.Plug.lpCurentBuffer = NULL then return 0
  if _Me.Plug.Buffersize     =    0 then return 0

  Buffersize=_Me.Plug.Buffersize
  lpBuffer  =_Me.Plug.lpCurentBuffer
  while (Buffersize>0) and (nErrors<3)
    ret=sys_write(_Me.hDevice,lpBuffer,Buffersize)
    if ret=EAGAIN then
      sleep 1
    elseif ret>0 then
      Buffersize-=ret
      lpBuffer  +=ret
    else
      nErrors+=1
      _Me.LastError="dsp:write unknow error ["+ str(ret) + "]!"
      dprint(_Me.LastError)
    end if
  wend
  return 1
end function

private _
sub Thread(_B unused as integer)
  dim as integer BufferCounter,ThreadID,ret,lpArg
  lpArg=cint(@_Me.Plug)
  _Me.Plug.lpCurentBuffer=_Me.Plug.lpBuffers[BufferCounter]
  _Me.Plug.FillBuffer(lpArg)
  while _Me.Plug.ThreadExit=false
    ret=DSPWrite()
    BufferCounter+=1:if BufferCounter=_Me.Plug.nBuffers then BufferCounter=0
    _Me.Plug.lpCurentBuffer=_Me.Plug.lpBuffers[BufferCounter]
    _Me.Plug.FillBuffer(lpArg)
  wend
end sub

private _
function NumOfDeviceNames() as integer
  return 3
end function

private _
function GetDeviceName(_B index as integer) as string
  select case index
    case 0
      return "/dev/dsp"
    case 1
      return "/dev/dsp1"
    case else
      return "/dev/sound/dsp"
  end select
end function

function plug_error() as string export
  dim tmp as string
  tmp=_Me.LastError
  return tmp
end function

function plug_isany(_R Plug as FBS_PLUG) as fbsboolean export
  dim as integer ret,i,j
  dim as FILEHANDLE tmp
  dprint("dsp:isany?")
  Plug.Plugname=_Me.Plug.Plugname
  _Me.Plug.DeviceName=""

  for i=0 to NumOfDeviceNames()-1
    tmp=sys_open(GetDeviceName(i), O_WRONLY or O_NONBLOCK)
    if (tmp = EAGAIN) then
      for j=1 to 5 ' try 5 seconds
        sleep 1000,1
        tmp = sys_open(GetDeviceName(i), O_WRONLY or O_NONBLOCK)
        if tmp>-1 then exit for
      next
    end if
    if tmp>-1 then 
      _Me.Plug.DeviceName=GetDeviceName(i)
      Plug.DeviceName=_Me.Plug.DeviceName
      exit for
    end if
  next
  if _Me.Plug.DeviceName="" then
    _Me.LastError="dsp:plug_isany error can't get any aviable device!"
    dprint(_Me.LastError)
    return false
  end if
  sys_close tmp
  return true
end function

function plug_start() as fbsboolean export
  dprint("dsp:start")
  if _Me.hDevice  =NULL then 
     _Me.Lasterror="dsp:plug_start error no device!"
     dprint(_Me.Lasterror)
    return false
  end if
  ' plug is running
  if _Me.Plug.ThreadID<>NULL then
    _Me.Lasterror="dsp:plug_start warning thread is running."
    dprint(_Me.Lasterror)
    return true
  end if
  _Me.Plug.ThreadExit=false
  _Me.Plug.ThreadID=ThreadCreate(cptr(any ptr,@Thread))
  if _Me.Plug.ThreadID=NULL then
    _Me.Lasterror="dsp:plug_start error can't create thread!"
    dprint(_Me.Lasterror)
    return false
  end if
  return true
end function

function  plug_stop() as fbsboolean export
  dprint("dsp:stop")
  if _Me.hDevice=NULL then 
    _Me.LastError="dsp:plug_stop error no device!"
    dprint(_Me.LastError)
    return false
  end if
  if _Me.Plug.ThreadID=NULL then
    _Me.LastError="dsp:plug_stop warning no thread to stop."
    dprint(_Me.LastError)
    return false
  end if
  _Me.Plug.ThreadExit=true
  Threadwait _Me.Plug.ThreadID
  _Me.Plug.ThreadID=NULL
  return true
end function

function plug_exit() as fbsboolean export
  dprint("dsp:exit")
  dim as integer i
  if _Me.hDevice=NULL then
    _Me.LastError="dsp:plug_exit warning no open device."
    dprint(_Me.LastError)
    return true
  end if
  if _Me.Plug.ThreadID<>NULL then plug_stop()
  if _Me.Plug.lpBuffers<>NULL then
    if _Me.Plug.nBuffers>0 then
      for i=0 to _Me.Plug.nBuffers-1
        if _Me.Plug.lpBuffers[i]<>NULL then 
          deallocate _Me.Plug.lpBuffers[i]
          _Me.Plug.lpBuffers[i]=NULL
        end if
      next
    end if
    deallocate _Me.Plug.lpBuffers
  end if
  _Me.Plug.lpBuffers=NULL
  _Me.Plug.lpCurentBuffer=NULL
  _Me.Plug.nBuffers=0
  _Me.Plug.lpCurentBuffer=NULL
  sys_close _Me.hDevice
  _Me.hDevice=NULL
  function=true
end function

function  plug_init (_R Plug as FBS_PLUG) as fbsboolean export
  dprint("dsp:init")
  dim as integer ret,cmd,arg

  ' !!! fix it !!!!
  if _Me.hDevice<>NULL then 
    _Me.LastError = "dsp:plug_init error device is open"
    dprint(_Me.LastError)
    return false
  end if

  'Overwrite device name
  if _Me.Plug.DeviceName="" then _Me.Plug.DeviceName="/dev/dsp"
  if plug.index>-1 then
    _Me.Plug.DeviceName=GetDeviceName(plug.index)
      .Plug.DeviceName=_Me.Plug.DeviceName
  end if

  Plug.fmt.nBits\=8
  Plug.fmt.nBits*=8
  if Plug.fmt.nRate<6000  then Plug.fmt.nRate=6000
  if Plug.fmt.nRate>96000 then Plug.fmt.nRate=96000
  if Plug.fmt.nBits< 8    then Plug.fmt.nbits=8
  if Plug.fmt.nBits>16    then Plug.fmt.nbits=16
  if Plug.fmt.nChannels<1 then Plug.fmt.nChannels=1
  if Plug.fmt.nChannels>2 then Plug.fmt.nChannels=2

  ret=sys_open(_Me.Plug.DeviceName, O_WRONLY or O_NONBLOCK)
  if ret<0 then
    _Me.LastError = "dsp:plug_init error can't open device ["+  _Me.Plug.DeviceName + "]!" 
    dprint(_Me.LastError)
    return false
  end if
  _Me.hDevice=ret
  cmd=SNDCTL_DSP_RESET:arg=0
  ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
  if ret <0 then 
    _Me.LastError="dsp:plug_ini error can't set SNDCTL_DSP_RESET!"
    dprint(_Me.LastError)
    sys_close _Me.hDevice
    _Me.hDevice=NULL
    return false
  end if

#if 0
  cmd=SNDCTL_DSP_NONBLOCK:arg=0
  ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
  if ret <0 then 
    _Me.LastError="dsp:plug_init error can't set none blocking mode!"
    dprint(_Me.LastError)
    sys_close _Me.hDevice
    return false
  end if
#endif

  ' !!! makes shorter values any sence !!!
  if Plug.nFrames<64 then Plug.nFrames=64

  if Plug.nBuffers <2 then Plug.nBuffers=2
  arg=Plug.nBuffers:arg=arg shl 16

  Plug.Framesize=(Plug.fmt.nBits\8)*Plug.fmt.nChannels
  Plug.Buffersize=Plug.nFrames*Plug.Framesize

  ' !!! fixe it to simple bit rotate !!!
  select case Plug.Buffersize
    case 0 to 16
      ret=4
    case 17 to 32
      ret=5
    case 33 to 64
      ret=6
    case 65 to 128
      ret=7
    case 129 to 256
      ret=8
    case 257 to 512
      ret=9
    case 513 to 1024
      ret=10
    case 1025 to 2048
      ret=11
    case 2049 to 4096
      ret=12
    case 4097 to 8192
      ret=13
    case 8193 to 16384
      ret=14
    case 16385 to 32768
      ret=15
    case else
      ret=16
  end select
  arg=arg or ret

  cmd=SNDCTL_DSP_SETFRAGMENT
  ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
  if ret <0 then 
    _Me.LastError="dsp:plug_init error can't set SNDCTL_DSP_SETFRAGMENT (nBuffers*Buffersize)!"
    dprint(_Me.LastError)
    sys_close _Me.hDevice
    _Me.hDevice=NULL
    return false
  end if

  Plug.nBuffers  =  hiword(arg)
  Plug.Buffersize=2^loword(arg)

  cmd=SNDCTL_DSP_SPEED:arg=Plug.fmt.nRate
  ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
  if ret <0 then 
    _Me.LastError="dsp: error can't set SNDCTL_DSP_SPEED (nRate) to [" + str(Plug.fmt.nRate) + "]!"
    dprint(_Me.LastError)
    sys_close _Me.hDevice
    _Me.hDevice=NULL
    return false
  end if

  if Plug.fmt.nBits=8 then
    ' first try signed 8 bit
    cmd=SNDCTL_DSP_SETFMT:arg=AFMT_S8
    ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
    if ret<0 then ' try unsigned 8 bit
      cmd=SNDCTL_DSP_SETFMT:arg=AFMT_U8
      ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
      ' not all devices supports 8 bit
      if ret<0 then 
        Plug.fmt.nBits=16
      else
        Plug.fmt.Signed=false
      end if
    else
      Plug.fmt.signed=true
    end if
  end if

  ' signed 16 bit litle endian
  if Plug.fmt.nBits=16 then
    cmd=SNDCTL_DSP_SETFMT:arg=AFMT_S16_LE
    ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
    ' not all devices supports 16 bit
    if ret<0 then
      Plug.fmt.nBits=8
      cmd=SNDCTL_DSP_SETFMT:arg=AFMT_S8
      ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
      if ret<0 then
        ' last hope unsigned 8 bit
        cmd=SNDCTL_DSP_SETFMT:arg=AFMT_U8
        ret=SYS_IOCTL(_Me.hDevice,cmd,@arg) 
        if ret<0 then
          _Me.LastError="dsp: error can't set SNDCTL_DSP_SETFMT (nBits)"
          dprint(_Me.LastError)
          sys_close _Me.hDevice
          _Me.hDevice=NULL
          return false
        else
          Plug.fmt.Signed=false
        end if
      else 
        Plug.fmt.Signed=true
      end if
    else
      Plug.fmt.Signed=true
    end if
  end if

  if Plug.fmt.nChannels=1 then 
    cmd=SNDCTL_DSP_CHANNELS:arg=1
    ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
    ' not all devices support mono
    if ret <0 then Plug.fmt.nChannels=2
  end if

  if Plug.fmt.nChannels=2 then 
    cmd=SNDCTL_DSP_CHANNELS:arg=2
    ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
    ' not all devices supports stereo
    if ret <0 then 
      Plug.fmt.nChannels=1
      cmd=SNDCTL_DSP_CHANNELS:arg=1
      ret=SYS_IOCTL(_Me.hDevice,cmd,@arg)
      if ret<0 then 
        _Me.LastError="dsp:plug_init error can't set SNDCTL_DSP_CHANNELS (nChannels)"
        dprint(_Me.LastError)
        sys_close _Me.hDevice
        _Me.hDevice=NULL
        return false
      end if
    end if
  end if
  'now device is open with an usable format
  _Me.Plug.Fmt.nRate    =Plug.fmt.nRate
  _Me.Plug.Fmt.nBits    =Plug.fmt.nBits
  _Me.Plug.Fmt.nChannels=Plug.fmt.nChannels
  _Me.Plug.Fmt.Signed   =Plug.fmt.Signed

  ' !!! Framessize and nFrames can be changed !!!
  Plug.Framesize=(Plug.fmt.nBits\8) * Plug.fmt.nChannels
  Plug.nFrames  = Plug.Buffersize\Plug.Framesize

  _Me.Plug.nBuffers  =Plug.nBuffers
  _Me.Plug.Buffersize=Plug.Buffersize
  _Me.Plug.nFrames   =Plug.nFrames
  _Me.Plug.Framesize =Plug.Framesize

  ' create our buffers
  _Me.Plug.lpBuffers=callocate(_Me.Plug.nBuffers*4)
  Plug.lpBuffers=_Me.Plug.lpBuffers
  for ret=0 to _Me.Plug.nBuffers-1
    _Me.Plug.lpBuffers[ret]=callocate(_Me.Plug.Buffersize)
    Plug.lpBuffers[ret]=_Me.Plug.lpBuffers[ret]
  next

  _Me.Plug.FillBuffer=Plug.FillBuffer
  return true ' i like it
end function
