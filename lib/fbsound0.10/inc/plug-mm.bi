'  ##############
' # plug-mm.bi #
'##############
#ifndef __FBS_PLUGOUT_MM__
#define __FBS_PLUGOUT_MM__
#inclib "winmm"
' API section enums and types
enum WAVE_FORMATS
  WAVE_FORMAT_1M08 =    1
  WAVE_FORMAT_1S08 =    2
  WAVE_FORMAT_1M16 =    4
  WAVE_FORMAT_1S16 =    8
  WAVE_FORMAT_2M08 =   16
  WAVE_FORMAT_2S08 =   32
  WAVE_FORMAT_2M16 =   64
  WAVE_FORMAT_2S16 =  128
  WAVE_FORMAT_4M08 =  256
  WAVE_FORMAT_4S08 =  512
  WAVE_FORMAT_4M16 = 1024
  WAVE_FORMAT_4S16 = 2048
end enum

type WAVEFORMATEX field=1
  wFormatTag       as short
  nChannels        as short
  nRate            as integer
  nBytesPerSec     as integer
  Framesize        as short
  nBits            as short
  ExtraSize        as short
end type

type WAVEOUTCAPS field=1
  Mid              as ushort
  Pid              as ushort
  DriverVersion    as integer
  ProductName      as zstring * 32
  Formats          as WAVE_FORMATS
  nChannels        as short
  Reserved         as short
  dwSupport        as uinteger
end type

enum OPENFLAGS
  CALLBACK_NULL     = &H0      ' no callback (default)
  CALLBACK_WINDOW   = &H10000  ' dwCallback is a HWND
  CALLBACK_TASK     = &H20000  ' dwCallback is a HTASK
  CALLBACK_FUNCTION = &H30000  ' dwCallback is a FARPROC
  CALLBACK_TYPEMASK = &H70000  ' callback type mask

  WAVE_FORMAT_QUERY        = &H1
  WAVE_ALLOWSYNC           = &H2
  WAVE_MAPPED              = &H4
  WAVE_FORMAT_DIRECT       = &H8
  WAVE_FORMAT_DIRECT_QUERY = &H9 '(WAVE_FORMAT_QUERY Or WAVE_FORMAT_DIRECT)
end enum
' waveOutproc messages
#define WOM_OPEN  &h3BB
#define WOM_CLOSE &h3BC
#define WOM_DONE  &h3BD

union WAVEDATA_PTR
  lp8   as ubyte ptr
  lp16  as short ptr
  lpAny as any   ptr
end union
'  flags for Flags field of WAVEHDR
enum WHDRFLAGS
  WHDR_DONE        = &H01 ' done bit
  WHDR_PREPARED    = &H02 ' set if this header has been prepared
  WHDR_BEGINLOOP   = &H04 ' loop start block
  WHDR_ENDLOOP     = &H08 ' loop end block
  WHDR_INQUEUE     = &H10 ' reserved for driver
  WHDR_VALID       = &H1F ' valid flags  (Internal)
end enum
type WAVEHDR 'field=1
  lpData           as ubyte ptr
  nBytes           as integer
  nBytesRecorded   as integer
  UserData         as integer
  Flags            as WHDRFLAGS
  Loops            as integer
  lpNext           as WAVEHDR ptr
  reserved         as integer
end type 

type SMPTETYPE field = 1
  hour             as byte
  min              as byte 
  sec              as byte
  frame            as byte 
  fps              as byte 
  dummy            as byte 
  pad(2)           as byte
end type

type MMTIME field=1
  timeformat as uinteger
  union
    ms      as uinteger
    sample  as uinteger
    cb      as uinteger
    ticks   as uinteger
    smpte   as SMPTETYPE
    songptr as uinteger
  end union
end type

#define MMSYSERR_ERROR         1
#define MMSYSERR_BADDEVICEID   2
#define MMSYSERR_NOTENABLED    3
#define MMSYSERR_ALLOCATED     4
#define MMSYSERR_INVALHANDLE   5
#define MMSYSERR_NODRIVER      6
#define MMSYSERR_NOMEM         7
#define MMSYSERR_NOTSUPPORTED  8
#define MMSYSERR_BADERRNUM     9
#define MMSYSERR_INVALFLAG     10
#define MMSYSERR_INVALPARAM    11
#define MMSYSERR_HANDLEBUSY    12
#define MMSYSERR_INVALIDALIAS  13
#define MMSYSERR_BADDB         14
#define MMSYSERR_KEYNOTFOUND   15
#define MMSYSERR_READERROR     16
#define MMSYSERR_WRITEERROR    17
#define MMSYSERR_DELETEERROR   18
#define MMSYSERR_VALNOTFOUND   19
#define MMSYSERR_NODRIVERCB    20
#define MMSYSERR_LASTERROR     20


' API section declares
declare function waveOutGetNumDevs alias "waveOutGetNumDevs" () as integer
declare function waveOutGetDevCaps alias "waveOutGetDevCapsA" ( _
  byval DriverId     as integer, _
  byval lpCAPS       as WAVEOUTCAPS ptr, _
  byval CapsSize     as integer) as integer

declare function waveOutOpen alias "waveOutOpen" ( _
  byval lphDriver    as integer ptr     , _
  byval DriverId     as integer         , _
  byval lpFormat     as WAVEFORMATEX ptr, _
  byval lpCall_HWnd  as any ptr         , _
  byval lpUserData   as any ptr         , _
  byval Flags        as OPENFLAGS) as integer

declare function waveOutClose alias "waveOutClose" ( _
  byval hDriver      as integer) as integer

declare function waveOutPrepareHeader alias "waveOutPrepareHeader" ( _
  byval hDriver      as integer, _ 
  byval lpHdr        as WAVEHDR ptr,_
  byval HdrSize      as integer) as integer

declare function waveOutUnprepareHeader alias "waveOutUnprepareHeader" ( _
  byval hDriver      as integer, _
  byval lpHdr        as WAVEHDR ptr, _ 
  byval HdrSize      as integer) as integer

declare function waveOutWrite alias "waveOutWrite" ( _
  byval hDevice as integer, _
  byval lpHdr   as WAVEHDR ptr, _ 
  byval HdrSize as integer) as integer

declare function waveOutPause alias "waveOutPause" ( _
  byval hDevice as integer) as integer

declare function waveOutRestart alias "waveOutRestart" ( _
  byval hDevice as integer) as integer

declare function waveOutReset alias "waveOutReset" ( _
  byval hDevice as integer) as integer

declare function waveOutGetPosition alias "waveOutGetPosition" ( _
  byval hDriver      as integer, _
  byval lpTime       as MMTIME ptr, _
  byval TimeSize     as integer) as integer


' API helper section

private sub copyasm(byval d as any ptr,byval s as any ptr,byval n as integer)
  if n<1 then exit sub
asm
  mov    edi,dword ptr [d]
  mov    esi,dword ptr [s]
  mov    ecx,dword ptr [n]

  shr    ecx,1
  jnc    copyasm_2
  movsb

copyasm_2:
  shr    ecx,1
  jnc    copyasm_4
  movsw

copyasm_4:
  jecxz  copyasm_end

copyasm_loop:
  movsd
  dec    ecx
  jnz    copyasm_loop
copyasm_end:
end asm
end sub


private _
function InitWaveFormatEx( _
  byref Format     as WAVEFORMATEX, _
  byval nRate      as integer, _
  byval nBits      as integer, _
  byval nChannels  as integer) as WAVE_FORMATS

  if nRate < 10026 then
    nRate=10025
  elseif nRate < 22051 then
    nRate=22050
  elseif nRate < 44101 then
    nRate=44100
  elseif nRate > 44100 then  
    nRate=44100
  end if
  nBits\=8
  if nBits < 1 then
    nBits=1
  elseif nBits > 2 then  
    nBits=2
  end if
  nBits=nBits shl 3

  if nChannels<2 then
    nChannels=1
  elseif nChannels>2 then
    nChannels=2
  end if

  with Format
   .wFormatTag       = 1  'PCM
   .nChannels        = nChannels
   .nRate            = nRate
   .nBits            = nBits
   .Framesize        =(nBits\8) * nChannels
   .nBytesPerSec     =(nBits\8) * nChannels * nRate
   .ExtraSize        =0
  end with

  select case nRate
    case 10025
      select case nBits
        case 8
          select case nChannels
            case 1:return WAVE_FORMAT_1M08
            case 2:return WAVE_FORMAT_1S08
          end select
        case 16
          select case nChannels
            case 1:return WAVE_FORMAT_1M16
            case 2:return WAVE_FORMAT_1S16
          end select
      end select
    case 22050
      select case nBits
        case 8
          select case nChannels
            case 1:return WAVE_FORMAT_2M08
            case 2:return WAVE_FORMAT_2S08
          end select
        case 16
          select case nChannels
            case 1:return WAVE_FORMAT_2M16
            case 2:return WAVE_FORMAT_2S16
          end select
      end select
    case 44100
      select case nBits
        case 8
          select case nChannels
            case 1:return WAVE_FORMAT_4M08
            case 2:return WAVE_FORMAT_4S08
          end select
        case 16
          select case nChannels
            case 1:return WAVE_FORMAT_4M16
            case 2:return WAVE_FORMAT_4S16
          end select
      end select  
  end select  
end function

private _
sub setWaveFormatex(byref wf        as WAVEFORMATEX, _
                    byval nRate     as integer, _
                    byval nBits     as integer, _
                    byval nChannels as integer)
  wf.wFormatTag  =1 ' PCM
  wf.nRate       =nRate
  wf.nBits       =nBits
  wf.nChannels   =nChannels
  wf.Framesize   =(nBits\8)*nChannels
  wf.nBytesPerSec=(nBits\8)*nChannels*nRate
  wf.ExtraSize=0
end sub

#endif '__FBS_PLUGOUT_MM__
