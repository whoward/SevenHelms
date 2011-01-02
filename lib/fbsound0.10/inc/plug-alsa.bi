'  ################
' # plug-alsa.bi #
'################
#ifndef __FBS_PLUGOUT_ALSA__
#define __FBS_PLUGOUT_ALSA__
const EIO                          = -5  ' I/O error
const EAGAIN                       = -11 ' Try again
const EPIPE                        = -32 ' Broken pipe
const EBADFD                       = -77 ' File descriptor in bad state
const ESTRPIPE                     = -86 ' Streams pipe error

const BLOCK                        = 0
const NONBLOCK                     = 1
const ASYNC                        = 2

const SND_PCM_STREAM_PLAYBACK      = 0
const SND_PCM_STREAM_CAPTURE       = 1

enum SND_PCM_FORMATS
  ' Signed 8 bit
  SND_PCM_FORMAT_S8 = 0
  ' Unsigned 8 bit
  SND_PCM_FORMAT_U8 = 1
  ' Signed 16 bit Little Endian 
  SND_PCM_FORMAT_S16_LE = 2
end enum

const SND_PCM_ACCESS_RW_INTERLEAVED= 3

type snd_pcm_t           as any ptr
type snd_pcm_hw_params_t as any ptr
type snd_pcm_sw_params_t as any ptr

' PCM
declare function snd_strerror cdecl alias "snd_strerror" ( _
byval ecode as integer) as zstring ptr

declare function snd_pcm_open cdecl alias "snd_pcm_open" ( _
byval pcm          as snd_pcm_t ptr, _
byval device       as string, _
byval direction    as integer, _
byval mode         as integer) as integer

declare function snd_pcm_hw_free cdecl alias "snd_pcm_hw_free" ( _
byval pcm          as snd_pcm_t) as integer

declare function snd_pcm_close cdecl alias "snd_pcm_close" ( _
byval pcm          as snd_pcm_t) as integer

declare function snd_pcm_start cdecl alias "snd_pcm_start" ( _
byval pcm          as snd_pcm_t) as integer

declare function snd_pcm_drain cdecl alias "snd_pcm_drain" ( _
byval pcm          as snd_pcm_t) as integer

declare function snd_pcm_nonblock cdecl alias "snd_pcm_nonblock" ( _
byval pcm          as snd_pcm_t, _
byval nonblock     as integer) as integer

declare function snd_pcm_prepare cdecl alias "snd_pcm_prepare" ( _
byval pcm          as snd_pcm_t) as integer

declare function snd_pcm_writei cdecl alias "snd_pcm_writei" ( _
byval pcm          as snd_pcm_t, _
byval buffer       as any ptr, _
byval size         as integer) as integer

declare function snd_pcm_avail_update cdecl alias "snd_pcm_avail_update" ( _
byval pcm          as snd_pcm_t) as integer

declare function snd_pcm_wait cdecl alias "snd_pcm_wait" ( _
byval pcm          as snd_pcm_t, _
byval msec         as integer) as integer

declare function snd_pcm_resume cdecl alias "snd_pcm_resume" ( _
byval pcm          as snd_pcm_t) as integer

'hardware
declare function snd_pcm_hw_params_malloc cdecl alias "snd_pcm_hw_params_malloc" ( _
byval hw           as snd_pcm_hw_params_t ptr) as integer

declare function snd_pcm_hw_params_any cdecl alias "snd_pcm_hw_params_any" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t) as integer

declare function snd_pcm_hw_params_set_access cdecl alias "snd_pcm_hw_params_set_access" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t, _
byval mode         as integer) as integer

declare function snd_pcm_hw_params_set_format cdecl alias "snd_pcm_hw_params_set_format" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t, _
byval fmt          as SND_PCM_FORMATS) as integer

declare function snd_pcm_hw_params_set_channels cdecl alias "snd_pcm_hw_params_set_channels" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t, _
byval Channels     as integer) as integer

declare function snd_pcm_hw_params_get_channels cdecl alias "snd_pcm_hw_params_get_channels" ( _
byval hw           as snd_pcm_hw_params_t, _
byval lpChannels   as integer ptr) as integer

declare function snd_pcm_hw_params_set_rate_near cdecl alias "snd_pcm_hw_params_set_rate_near" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t, _
byval lpRate       as integer ptr, _
byval lpDir        as integer ptr) as integer

declare function snd_pcm_hw_params_get_periods cdecl alias "snd_pcm_hw_params_get_periods" ( _
byval hw           as snd_pcm_hw_params_t, _
byval lpValue      as integer ptr, _
byval lpDir        as integer ptr) as integer

declare function snd_pcm_hw_params_set_periods cdecl alias "snd_pcm_hw_params_set_periods" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t, _
byval Value        as integer, _
byval lpDir        as integer) as integer

declare function snd_pcm_hw_params_set_periods_near cdecl alias "snd_pcm_hw_params_set_periods_near" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t, _
byval lpValue      as integer ptr, _
byval lpDir        as integer ptr) as integer

declare function snd_pcm_hw_params_set_period_size cdecl alias "snd_pcm_hw_params_set_period_size" ( _
byval pcm          as snd_pcm_t, _
byval params       as snd_pcm_hw_params_t, _
byval nFrames      as integer, _
byval lpDir        as integer ptr) as integer

declare function snd_pcm_hw_params_get_period_size cdecl alias "snd_pcm_hw_params_get_period_size" ( _
byval params       as snd_pcm_hw_params_t, _
byval lpFrames     as integer ptr, _
byval lpDir        as integer ptr) as integer

'int  snd_pcm_hw_params_set_period_size_near (snd_pcm_t *pcm, snd_pcm_hw_params_t *params, snd_pcm_uframes_t *val, int *dir)
declare function snd_pcm_hw_params_set_period_size_near cdecl alias "snd_pcm_hw_params_set_period_size_near" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t, _
byval lpValue      as integer ptr, _
byval lpDir        as integer ptr) as integer

declare function snd_pcm_hw_params_set_buffer_size cdecl alias "snd_pcm_hw_params_set_buffer_size" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t, _
byval Frames      as integer) as integer

declare function snd_pcm_hw_params_set_buffer_size_near cdecl alias "snd_pcm_hw_params_set_buffer_size_near" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t, _
byval lpFrames     as integer ptr) as integer

declare function snd_pcm_hw_params_get_buffer_size cdecl alias "snd_pcm_hw_params_get_buffer_size" ( _
byval hw           as snd_pcm_hw_params_t, _
byval lpFrames     as integer ptr) as integer

declare function snd_pcm_hw_params cdecl alias "snd_pcm_hw_params" ( _
byval pcm          as snd_pcm_t, _
byval hw           as snd_pcm_hw_params_t) as integer

declare sub snd_pcm_hw_params_free cdecl alias "snd_pcm_hw_params_free" ( _
byval hw           as snd_pcm_hw_params_t)

' software
declare function snd_pcm_sw_params_malloc cdecl alias "snd_pcm_sw_params_malloc" ( _
byval params       as snd_pcm_sw_params_t ptr) as integer

declare function snd_pcm_sw_params_current cdecl alias "snd_pcm_sw_params_current" ( _
byval pcm          as snd_pcm_t, _
byval params       as snd_pcm_sw_params_t ptr) as integer

declare function snd_pcm_sw_params_set_avail_min cdecl alias "snd_pcm_sw_params_set_avail_min" ( _
byval pcm          as snd_pcm_t, _
byval params       as snd_pcm_sw_params_t, _
byval value        as integer) as integer

declare function snd_pcm_sw_params_set_start_threshold cdecl alias "snd_pcm_sw_params_set_start_threshold" ( _
byval pcm          as snd_pcm_t,  _
byval params       as snd_pcm_sw_params_t, _
byval value        as integer) as integer

declare function snd_pcm_sw_params cdecl alias "snd_pcm_sw_params" ( _
byval pcm          as snd_pcm_t, _
byval params       as snd_pcm_sw_params_t) as integer

declare sub snd_pcm_sw_params_free cdecl alias "snd_pcm_sw_params_free" ( _
byval params       as snd_pcm_sw_params_t)

#inclib "asound"
#endif '__FBS_PLUGOUT_ALSA__