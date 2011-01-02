'  ###############
' # plug-dsp.bi #
'###############
#ifndef __FBS_PLUGOUT_DSP__
#define __FBS_PLUGOUT_DSP__
const _READ     = 3
const _WRITE    = 4
const _OPEN     = 5
const _CLOSE    = 6
const _ACCESS   = 33
const _IOCTL    = 54

const O_RDONLY   = 0
const O_WRONLY   = 1
const O_RDWR     = 2
const O_NONBLOCK = &H800

const EAGAIN    = -11
const EBUSY     = -16
const ENDEV     = -19

const SNDCTL_DSP_RESET      = &H00005000
const SNDCTL_DSP_SYNC       = &H00005001
const SNDCTL_DSP_POST       = &H00005008
const SNDCTL_DSP_NONBLOCK   = &H0000500e

const SNDCTL_DSP_SPEED      = &Hc0045002
const SNDCTL_DSP_STEREO     = &Hc0045003 '0=mono 1=stereo
const SNDCTL_DSP_GETBLKSIZE = &Hc0045004
const SNDCTL_DSP_SETFMT     = &Hc0045005

const SNDCTL_DSP_SAMPLESIZE = &Hc0045005 'same as _SETFMT
const SNDCTL_DSP_CHANNELS   = &Hc0045006 '1=mono 2=stereo
const SOUND_PCM_WRITE_FILTER= &Hc0045007

const SNDCTL_DSP_SUBDIVIDE  = &Hc0045009
const SNDCTL_DSP_SETFRAGMENT =&Hc004500A

'arg for SNDCTL_DSP_SETFMT cmd
const AFMT_MU_LAW    = &H00000001
const AFMT_A_LAW     = &H00000002
const AFMT_IMA_ADPCM = &H00000004
const AFMT_U8        = &H00000008
const AFMT_S16_LE    = &H00000010  ' Little endian signed 
const AFMT_S16_BE    = &H00000020  ' Big endian signed 16 
const AFMT_S8        = &H00000040
const AFMT_U16_LE    = &H00000080  ' Little endian U16 
const AFMT_U16_BE    = &H00000100  ' Big endian U16 
const AFMT_MPEG      = &H00000200  ' MPEG (2) audio 
const AFMT_AC3       = &H00000400  ' Dolby Digital AC3 

type FILEHANDLE as integer

function SYS_ACCESS(byval DeviceName as string,byval mode as integer) as integer
asm
  mov eax, _ACCESS
  mov ebx, [DeviceName]
  mov ecx, [mode]
  int &H80
  mov [function],eax
end asm
end function

function SYS_OPEN(byval DeviceName as string,byval flag as integer,byval mode as integer=0) as integer
asm
  mov eax, _OPEN
  mov ebx, [DeviceName]
  mov ecx, [flag]
  mov edx, [mode]
  int &H80
  mov [function],eax
end asm
end function

function SYS_IOCTL (byval hDevice as FILEHANDLE,byval io_cmd as integer,byval lpArg as integer ptr) as integer
asm
  mov eax, _IOCTL
  mov ebx, [hDevice]
  mov ecx, [io_cmd]
  mov edx, [lpArg]
  int &H80
  mov [function],eax
end asm
end function

function SYS_WRITE (byval hDevice as FILEHANDLE,byval lpBuffer as any ptr,byval Buffersize as integer) as integer
asm
  mov eax, _WRITE
  mov ebx, [hDevice]
  mov ecx, [lpBuffer]
  mov edx, [BufferSize]
  int &H80
  mov [function],eax
end asm
end function

function SYS_READ(byval hDevice as FILEHANDLE,byval lpBuffer as any ptr,byval Buffersize as integer) as integer
asm
  mov eax, _READ
  mov ebx, [hDevice]
  mov ecx, [lpBuffer]
  mov edx, [Buffersize]
  int &H80
  mov [function],eax
end asm
end function

function SYS_CLOSE(byval hDevice as FILEHANDLE) as integer
asm
  mov eax, _CLOSE
  mov ebx, [hDevice]
  int &H80
  mov [function],eax
end asm
end function

#endif '__FBS_PLUGOUT_DSP__