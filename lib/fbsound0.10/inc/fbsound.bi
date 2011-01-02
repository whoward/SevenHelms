'  ##############
' # fbsound.bi #
'##############
' copyright D.J.Peters (Joshy)
' d.j.peters@web.de

#ifndef __FBSOUND_BI__
#define __FBSOUND_BI__

#ifdef __FB_WIN32__
# inclib "fbsoundwin"
#else
# ifdef __FB_LINUX__
#  inclib "fbsoundlin"
# else
#  error target must be WIN32 or Linux x86 !
# endif
#endif

#include "fbstypes.bi"
#include "fbscpu.bi"
#include "mad.bi"
#include "fbsdsp.bi"

' _DF = declare function
' _DS = declare sub
' _B  = byval
' _R  = byref

_DF FBS_Get_Keycode            () As FBS_KEYCODES

_DF FBS_Init                   (_B nRate      as integer=44100, _
                                _B nChannels  as integer=    2, _
                                _B nBuffers   as integer=    3, _
                                _B nFrames    as integer= 2048, _
                                _B index      as integer=   -1) as fbsboolean

' now fbs will start,stop and exit by it self
_DF FBS_Start                  () as fbsboolean
_DF FBS_Stop                   () as fbsboolean
_DF FBS_Exit                   () as fbsboolean

_DF FBS_Get_PlugPath           () as string
_DS FBS_Set_PlugPath           (_B NewPath as string)

_DF FBS_Get_NumOfPlugouts      () as integer
_DF FBS_Get_PlugName           () as string
_DF FBS_Get_PlugDevice         () as string
_DF FBS_Get_PlugError          () as string
_DF FBS_Get_PlugRate           () as integer ' 6000-96000
_DF FBS_Get_PlugBits           () as integer ' curently 16bit only
_DF FBS_Get_PlugChannels       () as integer ' 1=mono 2=stereo
_DF FBS_Get_PlugBuffers        () as integer ' 2 to N N<=64
_DF FBS_Get_PlugBuffersize     () as integer ' same as FrameSize*Frames
_DF FBS_Get_PlugFrames         () as integer ' same as BufferSize\FrameSize
_DF FBS_Get_PlugFramesize      () as integer ' same as BufferSize\Frames
_DF FBS_Get_PlugRunning        () as fbsboolean

_DF FBS_Get_PlayingSounds      () as integer
_DF FBS_Get_PlayingStreams     () as integer
_DF FBS_Get_PlayedBytes        () as integer
_DF FBS_Get_PlayedSamples      () as integer
_DF FBS_Get_PlayTime           () as DOUBLE


_DF FBS_Get_MasterVolume       (_B lpVolume as single ptr) as fbsboolean
_DF FBS_Set_MasterVolume       (_B Volume   as single ) as fbsboolean

_DF FBS_Set_MasterFilter       (_B nFilter as integer, _
                                _B Center  as single, _
                                _B dB      as single, _
                                _B Octave  as single = 1.0, _
                                _B OnOff   as fbsboolean = True) as fbsboolean

_DF FBS_Enable_MasterFilter    (_B nFilter as integer) as fbsboolean
_DF FBS_Disable_MasterFilter   (_B nFilter as integer) as fbsboolean

_DS FBS_PitchShift             ( _B d as short ptr, _
                                 _B s as short ptr, _
                                 _B v as single   , _
                                 _B n as integer  )

_DF FBS_Get_MaxChannels        (_B lpnChannels as integer ptr) as fbsboolean
_DF FBS_Set_MaxChannels        (_B nChannels   as integer ) as fbsboolean



_DF FBS_Set_MasterCallback     (_B lpCallback as FBS_BUFFERCALLBACK) as fbsboolean
_DF FBS_Enable_MasterCallback  ()                   as fbsboolean
_DF FBS_Disable_MasterCallback ()                   as fbsboolean

' create or load wave objects in the pool of Waves()

' create hWave from *.wav file
_DF FBS_Load_WAVFile           (_B Filename as string       , _
                                _B hWave    as integer ptr       ) as fbsboolean
' create hWave from *.mp3,*.mp2,*.mp file
_DF FBS_Load_MP3File           (_B Filename as string       , _
                                _B lphWave  as integer ptr       , _
                                _B tmpfile  as string =""   ) as fbsboolean
' create hWave from *.ogg file
_DF FBS_Load_OGGFile           (_B Filename as string       , _
                                _B lphWave  as integer ptr       , _
                                _B tmpfile  as string =""   ) as fbsboolean

' create hWave with nSamples in memory
_DF FBS_Create_Wave            (_B nSamples as integer        , _
                                _B hWave    as integer ptr       , _
                                _B lpWave   as any ptr ptr      ) as fbsboolean
' playtime in MS
_DF FBS_Get_WaveLength         (_B hWave    as integer        , _
                                _B lpMS     as integer ptr       ) as fbsboolean



' play any wave as sound from the pool of Waves()
' optional number of loops, playbackspeed,volume,pan
' if you need to change any param while playing use an hSound object
_DF FBS_Play_Wave              (_B hWave    as integer        , _
                                _B nLoops   as integer  = 1   , _
                                _B Speed    as single  = 1.0 , _
                                _B Volume   as single  = 1.0 , _
                                _B Pan      as single  = 0.0 , _
                                _B hSound   as integer ptr = NULL) as fbsboolean

'create an playable sound object "hSound" from any "hWave" object
_DF FBS_Create_Sound           (_B hWave    as integer        , _
                                _B lphSound as integer ptr = NULL) as fbsboolean


' [optinal] destroy/free created hSound's and hWave's
_DF FBS_Destroy_Wave           (_B lphWave  as integer ptr       ) as fbsboolean
_DF FBS_Destroy_Sound          (_B lphSound as integer ptr       ) as fbsboolean

' play an hSound object
_DF FBS_Play_Sound             (_B hSound   as integer        , _
                                _B nLoops   as integer = 1    ) as fbsboolean
' play time in MS
_DF FBS_Get_SoundLength        (_B hSound   as integer        , _
                                _B lpMS     as integer ptr       ) as fbsboolean


' get and set any params from playing hSound
_DF FBS_Set_SoundSpeed         (_B hSound   as integer        , _
                                _B Speed    as single=1.0    ) as fbsboolean
_DF FBS_Get_SoundSpeed         (_B hSound   as integer        , _
                                _B lpSpeed  as single ptr       ) as fbsboolean

_DF FBS_Set_SoundVolume        (_B hSound   as integer        , _
                                _B Volume   as single        ) as fbsboolean
_DF FBS_Get_SoundVolume        (_B hSound   as integer        , _
                                _B lpVolume as single ptr     ) as fbsboolean

_DF FBS_Set_SoundPan           (_B hSound   as integer        , _
                                _B Pan      as single=0.0    ) as fbsboolean
_DF FBS_Get_SoundPan           (_B hSound   as integer        , _
                                _B lpPan    as single ptr     ) as fbsboolean

_DF FBS_Set_SoundLoops         (_B hSound   as integer        , _
                                _B nLoops   as integer=1      ) as fbsboolean
_DF FBS_Get_SoundLoops         (_B hSound   as integer        , _
                                _B lpnLoops as integer ptr    ) as fbsboolean
' togle hearing
_DF FBS_Set_SoundMuted         (_B hSound   as integer        , _
                                _B muted    as fbsboolean     ) as fbsboolean
_DF FBS_Get_SoundMuted         (_B hSound   as integer        , _
                                _B lpMuted  as fbsboolean ptr ) as fbsboolean
' togle playing
_DF FBS_Set_SoundPaused        (_B hSound   as integer        , _
                                _B Paused   as fbsboolean     ) as fbsboolean
_DF FBS_Get_SoundPaused        (_B hSound   as integer        , _
                                _B lpPaused as fbsboolean ptr ) as fbsboolean

_DF fbs_Get_WavePointers       (_B hWave         as integer            , _
                                _B lplpWaveStart as short ptr ptr=NULL , _
                                _B lplpWaveEnd   as short ptr ptr=NULL , _
                                _B lpnChannels   as integer ptr  =NULL ) as fbsboolean

_DF fbs_Get_SoundPointers      (_B hSound    as integer       , _
                                _B lplpStart as short ptr ptr=NULL , _
                                _B lplpPlay  as short ptr ptr=NULL , _
                                _B lplpEnd   as short ptr ptr=NULL) as fbsboolean

_DF fbs_Set_SoundPointers      (_B hSound     as integer , _
                                _B lpNewStart as short ptr=NULL, _
                                _B lpNewPlay  as short ptr=NULL, _
                                _B lpNewEnd   as short ptr=NULL) as fbsboolean

_DF FBS_Set_SoundCallback      (_B hSound     as integer      , _
                                _B lpCallback as FBS_BUFFERCALLBACK)  as fbsboolean
_DF FBS_Enable_SoundCallback   (_B hSound     as integer      ) as fbsboolean
_DF FBS_Disable_SoundCallback  (_B hSound     as integer      ) as fbsboolean



' create/play local WAV,MP3,OGG
enum FBS_STREAM_TYPES
  'FBS_WAV
  FBS_MP3
  'FBS_OGG
end enum
'_DF FBS_Create_Stream          (_B Filename   as string,_B StreamID as integer ptr) as fbsboolean

_DF FBS_Create_MP3Stream       (_B Filename   as string   ) as fbsboolean
_DF FBS_Play_MP3Stream         (_B Volume     as single=1.0, _
                                _B Pan        as single=0.0) as fbsboolean

_DF FBS_Set_StreamVolume       (_B Volume     as single=1.0) as fbsboolean
_DF FBS_Get_StreamVolume       (_B Volume     as single ptr   ) as fbsboolean
_DF FBS_Set_StreamPan          (_B Pan        as single=0.0) as fbsboolean
_DF FBS_Get_StreamPan          (_B lpPan      as single ptr   ) as fbsboolean

_DF FBS_Get_StreamBuffer       (_B lpBuffer   as short ptr ptr , _
                                _B lpChannels as integer ptr   , _
                                _B lpnSamples as integer ptr   ) as fbsboolean

_DF FBS_Set_StreamCallback     (_B lpCallback as FBS_BUFFERCALLBACK)  as fbsboolean
_DF FBS_Enable_StreamCallback  () as fbsboolean
_DF FBS_Disable_StreamCallback () as fbsboolean
' optional end an free an playing MP3 stream
_DF FBS_End_MP3Stream          () as fbsboolean


#endif ' __FBSOUND_BI__
