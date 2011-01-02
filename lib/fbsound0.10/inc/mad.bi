'  ##########
' # mad.bi #
'##########
#IFNDEF __MAD_BI__
#define __MAD_BI__

#ifdef __FB_WIN32__
# inclib "madwin"
#else
# inclib "madlin"
#endif

#define FPM_INTEL
#define SIZEOF_INT 4
#define SIZEOF_LONG 4
#define SIZEOF_LONG_LONG 8

extern mad_version   alias "mad_version"   as zstring ptr
extern mad_copyright alias "mad_copyright" as zstring ptr
extern mad_author    alias "mad_author"    as zstring ptr
extern mad_build     alias "mad_build"     as zstring ptr

type mad_fixed_t     as integer
type mad_sample_t    as mad_fixed_t

#define MAD_F_FRACBITS  28
#define MAD_F_SCALEBITS MAD_F_FRACBITS
#define MAD_F(x) (x##L)
#define MAD_F_ONE &H10000000L
#define MAD_F_MIN &H80000000L
#define MAD_F_MAX &H7fffffffL

private _
function mad_f_mul( _
  _B a as mad_fixed_t, _
  _B b as mad_fixed_t) as mad_fixed_t
  asm 
  mov eax,dword ptr [a]
  imul dword    ptr [b]
  shrd eax, edx, 28
  mov [function],eax
  end asm
end function

' C routines
declare function mad_f_abs cdecl alias "mad_f_abs" (byval a as mad_fixed_t) as mad_fixed_t
declare function mad_f_div cdecl alias "mad_f_div" (byval a as mad_fixed_t, _
                                                    byval b as mad_fixed_t) as mad_fixed_t

type mad_bitptr field=1
  as byte ptr lpByte
  as ushort    cache
  as ushort    left
end type

#define mad_bit_finish(bitptr) ' nothing 
#define mad_bit_bitsleft(bitptr)  ((bitptr)->left)

declare sub mad_bit_init cdecl alias "mad_bit_init" ( _
  byval lpBitptr as mad_bitptr ptr, _
  byval lpBytes  as ubyte ptr)

declare function mad_bit_length cdecl alias "mad_bit_length" ( _
  byval lpBitptra as mad_bitptr ptr, _
  byval lpBitptrb as mad_bitptr ptr) as uinteger

declare function mad_bit_nextbyte cdecl alias "mad_bit_nextbyte" ( _
  byval lpBitptr as mad_bitptr ptr) as byte ptr

declare sub mad_bit_skip cdecl alias "mad_bit_skip" ( _
  byval lpBitptr as mad_bitptr ptr, _
  byval nBytes   as uinteger)

declare function mad_bit_read cdecl alias "mad_bit_read" ( _
  byval lpBitptr as mad_bitptr ptr, _
  byval nBytes   as uinteger) as uinteger

declare sub mad_bit_write cdecl alias "mad_bit_write" ( _
  byval lpBitptr as mad_bitptr ptr, _
  byval v1       as uinteger, _
  byval v2       as uinteger)

declare function mad_bit_crc cdecl alias "mad_bit_crc" ( _
  byval lpBitptr as mad_bitptr, _
  byval a        as uinteger, _
  byval b        as ushort) as ushort

type mad_timer_t
  as long  seconds  ' whole seconds 
  as ulong fraction ' 1/MAD_TIMER_RESOLUTION seconds 
end type
extern mad_timer_zero alias "mad_timer_zero" as mad_timer_t

#define MAD_TIMER_RESOLUTION 352800000UL

enum mad_units
  MAD_UNITS_HOURS        = -2
  MAD_UNITS_MINUTES      = -1
  MAD_UNITS_SECONDS      =  0

  ' metric units 
  MAD_UNITS_DECISECONDS  =   10
  MAD_UNITS_CENTISECONDS =  100
  MAD_UNITS_MILLISECONDS = 1000

  ' audio sample units
  MAD_UNITS_8000_HZ    =  8000
  MAD_UNITS_11025_HZ   = 11025
  MAD_UNITS_12000_HZ   = 12000
  MAD_UNITS_16000_HZ   = 16000
  MAD_UNITS_22050_HZ   = 22050
  MAD_UNITS_24000_HZ   = 24000
  MAD_UNITS_32000_HZ   = 32000
  MAD_UNITS_44100_HZ   = 44100
  MAD_UNITS_48000_HZ   = 48000

  ' video frame/field units 
  MAD_UNITS_24_FPS     =    24
  MAD_UNITS_25_FPS     =    25
  MAD_UNITS_30_FPS     =    30
  MAD_UNITS_48_FPS     =    48
  MAD_UNITS_50_FPS     =    50
  MAD_UNITS_60_FPS     =    60

  ' CD audio frames 
  MAD_UNITS_75_FPS     =    75

  ' video drop-frame units 
  MAD_UNITS_23_976_FPS =   -24
  MAD_UNITS_24_975_FPS =   -25
  MAD_UNITS_29_97_FPS  =   -30
  MAD_UNITS_47_952_FPS =   -48
  MAD_UNITS_49_95_FPS  =   -50
  MAD_UNITS_59_94_FPS  =   -60
end enum

#define mad_timer_reset(mtime) ((mtime) = mad_timer_zero)
#define mad_timer_sign(mtime) mad_timer_compare((mtime), mad_timer_zero)

declare function mad_timer_compare cdecl alias "mad_timer_compare" ( _
  byref a as mad_timer_t, _
  byref b as mad_timer_t) as integer

declare sub mad_timer_negate cdecl alias "mad_timer_negate" ( _
  byval lpTimer as mad_timer_t ptr)

declare function mad_timer_abs cdecl alias "mad_timer_abs" ( _
   byref mTimer as mad_timer_t) as mad_timer_t

declare sub mad_timer_add cdecl alias "mad_timer_add" ( _
  byval lpTimer   as mad_timer_t ptr, _
  byref mTimerAdd as mad_timer_t)

declare sub mad_timer_multiply cdecl alias "mad_timer_multiply" ( _
  byval lptimer as mad_timer_t ptr, _
  byval value   as integer)

declare function mad_timer_count cdecl alias "mad_timer_count" ( _
  byref mTimer  as mad_timer_t    , _
  byval as mad_units) as integer

declare function mad_timer_fraction cdecl alias "mad_timer_fraction" ( _
  byref mTimer  as mad_timer_t    , _
  byval value   as uinteger) as uinteger

declare sub mad_timer_set cdecl alias "mad_timer_set" ( _
  byval lpTimer as mad_timer_t ptr, _
  byval a as uinteger , _
  byval b as uinteger , _
  byval c as uinteger )

declare sub mad_timer_string cdecl alias "mad_timer_string" ( _
  byref mTimer as mad_timer_t , _ 
  byval strA as zstring ptr      , _
  byval atrB as zstring ptr     , _
  byval A as mad_units , _
  byval B as mad_units , _
  byval C as uinteger         )

#define MAD_BUFFER_GUARD 8
#define MAD_BUFFER_MDLEN (511 + 2048 + MAD_BUFFER_GUARD)

enum mad_error 
  MAD_ERROR_NONE           = &H0000 ' no error

  MAD_ERROR_BUFLEN         = &H0001 ' input buffer too small (or EOF)
  MAD_ERROR_BUFPTR         = &H0002 ' invalid (null) buffer pointer

  MAD_ERROR_NOMEM          = &H0031 ' not enough memory

  MAD_ERROR_LOSTSYNC       = &H0101 ' lost synchronization
  MAD_ERROR_BADLAYER       = &H0102 ' reserved header layer value
  MAD_ERROR_BADBITRATE     = &H0103 ' forbidden bitrate value
  MAD_ERROR_BADSAMPLERATE  = &H0104 ' reserved sample frequency value
  MAD_ERROR_BADEMPHASIS    = &H0105 ' reserved emphasis value

  MAD_ERROR_BADCRC         = &H0201 ' CRC check failed
  MAD_ERROR_BADBITALLOC    = &H0211 ' forbidden bit allocation value
  MAD_ERROR_BADSCALEFACTOR = &H0221 ' bad scalefactor index
  MAD_ERROR_BADMODE        = &H0222 ' bad bitrate/mode combination
  MAD_ERROR_BADFRAMELEN    = &H0231 ' bad frame length
  MAD_ERROR_BADBIGVALUES   = &H0232 ' bad big_values count
  MAD_ERROR_BADBLOCK_TYPE  = &H0233 ' reserved block_type
  MAD_ERROR_BADSCFSI       = &H0234 ' bad scalefactor selection info
  MAD_ERROR_BADDATAPTR     = &H0235 ' bad main_data_begin pointer
  MAD_ERROR_BADPART3LEN    = &H0236 ' bad audio data length
  MAD_ERROR_BADHUFFTABLE   = &H0237 ' bad Huffman table select
  MAD_ERROR_BADHUFFDATA    = &H0238 ' Huffman data overrun
  MAD_ERROR_BADSTEREO      = &H0239 ' incompatible block_type for JS
end enum

#define MAD_RECOVERABLE(error) ((error) and &Hff00)

type mad_stream
  as byte ptr     buffer     ' input bitstream buffer
  as byte ptr     bufend     ' end of buffer
  as uinteger     skiplen    ' bytes to skip before next frame
  as integer      sync       ' stream sync found
  as uinteger     freerate   ' free bitrate (fixed)

  as byte ptr     this_frame ' start of current frame
  as byte ptr     next_frame ' start of next frame
  as mad_bitptr   bit_ptr    ' current processing bit pointer

  as mad_bitptr   anc_ptr    ' ancillary bits pointer
  as uinteger     anc_bitlen ' number of ancillary bits

  as byte ptr     main_data  '(MAD_BUFFER_MDLEN) '-1 Layer III main_data()
  as uinteger     md_len     ' bytes in main_data

  as integer options    ' decoding options (see below)
  as integer error      ' error code (see above)
end type

enum
  MAD_OPTION_IGNORECRC      = &H0001 ' ignore CRC errors 
  MAD_OPTION_HALFSAMPLERATE = &H0002 ' generate PCM at 1/2 sample rate 
end enum
#define mad_stream_options(stream, opts) ((stream)->options = (opts))

declare sub mad_stream_init cdecl alias "mad_stream_init" ( _
  byval stream   as mad_stream ptr)

declare sub mad_stream_finish cdecl alias "mad_stream_finish" ( _
  byval stream   as mad_stream ptr)

declare sub mad_stream_buffer cdecl alias "mad_stream_buffer" ( _
  byval stream   as mad_stream ptr , _
  byval lpBuffer as ubyte      ptr , _
  byval buf_size as integer               )

declare sub mad_stream_skip cdecl alias "mad_stream_skip" ( _
  byval stream   as mad_stream ptr , _
  byval n        as uinteger       )

declare function mad_stream_sync cdecl alias "mad_stream_sync" ( _
  byval stream   as mad_stream ptr ) as integer

declare function mad_stream_errorstr cdecl alias "mad_stream_errorstr" ( _
  byval stream   as mad_stream ptr ) as zstring ptr

enum mad_layer
  MAD_LAYER_I   = 1 ' Layer I
  MAD_LAYER_II      ' Layer II
  MAD_LAYER_III     ' Layer III
end enum

enum mad_mode
  MAD_MODE_SINGLE_CHANNEL = 0 ' single channel
  MAD_MODE_DUAL_CHANNEL   = 1 ' dual channel
  MAD_MODE_JOINT_STEREO   = 2 ' joint (MS/intensity) stereo
  MAD_MODE_STEREO         = 3 ' normal LR stereo
end enum

enum mad_emphasis
  MAD_EMPHASIS_NONE       = 0 ' no emphasis
  MAD_EMPHASIS_50_15_US   = 1 ' 50/15 microseconds emphasis
  MAD_EMPHASIS_CCITT_J_17 = 3 ' CCITT J.17 emphasis
  MAD_EMPHASIS_RESERVED   = 2 ' unknown emphasis
end enum
' !!! no field=1
type mad_header
  as mad_layer     layer          ' audio layer (1, 2, or 3)
  as mad_mode      mode           ' channel mode (see above)
  as integer       mode_extension ' additional mode info
  as mad_emphasis  emphasis       ' de-emphasis to use (see above)
  as uinteger      bitrate        ' stream bitrate (bps)
  as uinteger      samplerate     ' sampling frequency (Hz)
  as ushort        crc_check      ' frame CRC accumulator
  as ushort        crc_target     ' final target CRC checksum
  as integer       flags          ' flags (see below)
  as integer       private_bits   ' private bits (see below)
  as mad_timer_t   duration       ' audio playing time of frame
end type

type mad_frame
  as mad_header      header            ' MPEG audio header
  as integer         options           ' decoding options (from stream)
  as mad_fixed_t     sbsample(1,35,31) ' synthesis subband filter samples
  as mad_fixed_t ptr overlap (1,31,17) ' Layer III block overlap data
end type

#define MAD_NCHANNELS(header)   (iif ((header)->mode>0,2,1))
#define MAD_NSBSAMPLES(header)  (iff ((header)->layer = MAD_LAYER_I    , 12, _
                                 iff ((header)->layer = MAD_LAYER_III and _
                                      (header)->flags and MAD_FLAG_LSF_EXT)),18,36) _
                                )

enum MAD_FLAGS
  MAD_FLAG_NPRIVATE_III = &H0007 ' number of Layer III private bits
  MAD_FLAG_INCOMPLETE   = &H0008 ' header but not data is decoded

  MAD_FLAG_PROTECTION   = &H0010 ' frame has CRC protection
  MAD_FLAG_COPYRIGHT    = &H0020 ' frame is copyright
  MAD_FLAG_ORIGINAL     = &H0040 ' frame is original (else copy)
  MAD_FLAG_PADDING      = &H0080 ' frame has additional slot

  MAD_FLAG_I_STEREO     = &H0100 ' uses intensity joint stereo
  MAD_FLAG_MS_STEREO    = &H0200 ' uses middle/side joint stereo
  MAD_FLAG_FREEFORMAT   = &H0400 ' uses free format bitrate

  MAD_FLAG_LSF_EXT      = &H1000 ' lower sampling freq. extension
  MAD_FLAG_MC_EXT       = &H2000 ' multichannel audio extension
  MAD_FLAG_MPEG_2_5_EXT = &H4000 ' MPEG 2.5 (unofficial) extension
end enum

enum
  MAD_PRIVATE_HEADER    = &H0100 ' header private bit
  MAD_PRIVATE_III       = &H001f ' Layer III private bits (up to 5)
end enum

#define mad_header_finish(header)  ' nothing 
declare sub mad_header_init cdecl alias "mad_header_init" ( _
  byval lpHeader as mad_header ptr )

declare function mad_header_decode cdecl alias "mad_header_decode" ( _
  byval lpHeader as mad_header ptr , _
  byval lpStream as mad_stream ptr ) as integer

declare sub mad_frame_init cdecl alias "mad_frame_init" ( _
  byval lpFrame as mad_frame ptr )

declare sub mad_frame_finish cdecl alias "mad_frame_finish" ( _
  byval lpFrame as  mad_frame ptr )

declare function mad_frame_decode cdecl alias "mad_frame_decode" ( _
  byval lpFrame  as mad_frame  ptr , _
  byval lpStream as mad_stream ptr ) as integer

declare sub mad_frame_mute cdecl alias "mad_frame_mute" ( _
  byval lpFrame as mad_frame ptr )

type mad_pcm
  as uinteger    samplerate         ' sampling frequency (Hz)
  as ushort      channels           ' number of channels
  as ushort      length             ' number of samples per channel
  as mad_fixed_t samples(1,1151)    ' PCM output samples [ch][sample]
end type

type mad_synth
  as mad_fixed_t filter(1,1,1,15,7) ' polyphase filterbank outputs [ch][eo][peo][s][v]
  as uinteger    phase              ' current processing phase
  as mad_pcm     pcm                ' PCM output
end type

' single channel PCM selector
enum
  MAD_PCM_CHANNEL_SINGLE = 0
end enum

' dual channel PCM selector
enum
  MAD_PCM_CHANNEL_DUAL_1 = 0
  MAD_PCM_CHANNEL_DUAL_2 = 1
end enum

' stereo PCM selector
enum
  MAD_PCM_CHANNEL_STEREO_LEFT  = 0
  MAD_PCM_CHANNEL_STEREO_RIGHT = 1
end enum

#define mad_synth_finish(synth) ' nothing
declare sub mad_synth_init cdecl alias "mad_synth_init"  ( _
  byval lpSynth as mad_synth ptr )

declare sub mad_synth_mute cdecl alias "mad_synth_mute"  ( _
  byval lpSynth as mad_synth ptr )

declare sub mad_synth_frame cdecl alias "mad_synth_frame" ( _
  byval lpSynth as mad_synth ptr , _
  byval lpFrame as mad_frame ptr )

enum mad_decoder_mode
  MAD_DECODER_MODE_SYNC  = 0
  MAD_DECODER_MODE_ASYNC
end enum

enum mad_flow
  MAD_FLOW_CONTINUE = &H0000 ' continue normally
  MAD_FLOW_STOP     = &H0010 ' stop decoding normally
  MAD_FLOW_BREAK    = &H0011 ' stop decoding and signal an error
  MAD_FLOW_IGNORE   = &H0020 ' ignore the current frame
end enum

type INPUT_CALLBACK_t as function cdecl ( _
  byval A     as any ptr , _
  byval lpStr as mad_stream ptr ) as integer

type HEADER_CALLBACK_t as function cdecl ( _
  byval A as any ptr , _
  byval lpHdr as mad_header ptr ) as integer

type FILTER_CALLBACK_t as function cdecl ( _
  byval A as any ptr , _ 
  byval lpStr as mad_stream ptr , _
  byval lpFrm as mad_frame  ptr ) as integer

type OUTPUT_CALLBACK_t as function cdecl ( _
  byval A as any ptr , _
  byval lpHdr as mad_header ptr ,_
  byval lpPCM as mad_pcm    ptr ) as integer

type ERROR_CALLBACK_t as function cdecl ( _
  byval A as any ptr , _
  byval lpStr as mad_stream ptr ,_
  byval lpFrm as mad_frame  ptr ) as integer

type MESSAGE_CALLBACK_t as function cdecl ( _
  byval A     as any ptr , _
  byval lpA2  as any ptr , _
  byval lpInt as integer ptr) as integer

type ASYNC_t
  as integer pid
  as integer in
  as integer out
end type

type SYNC_t
  as mad_stream    stream
  as mad_frame     frame
  as mad_synth     synth
end type

type MAD_DECODER
  as mad_decoder_mode mode
  as integer       options

  as ASYNC_t       async
  as SYNC_t ptr    sync

  as any ptr       cb_data

  as INPUT_CALLBACK_t   input_func
  as HEADER_CALLBACK_t  header_func
  as FILTER_CALLBACK_t  filter_func
  as OUTPUT_CALLBACK_t  output_func
  as ERROR_CALLBACK_t   error_func
  as MESSAGE_CALLBACK_t message_func
end type

declare sub mad_decoder_init cdecl alias "mad_decoder_init" ( _
  byval decoder      as mad_decoder ptr    , _
  byval buffer       as any ptr                  , _
  byval input_func   as INPUT_CALLBACK_t   , _
  byval header_func  as HEADER_CALLBACK_t  , _
  byval filter_func  as FILTER_CALLBACK_t  , _
  byval output_func  as OUTPUT_CALLBACK_t  , _
  byval error_func   as ERROR_CALLBACK_t   , _
  byval message_func as MESSAGE_CALLBACK_t )

declare function mad_decoder_finish cdecl alias "mad_decoder_finish" ( _ 
  byval lpDecoder    as mad_decoder ptr) as integer

#define mad_decoder_options(decoder, opts)  ((void) ((decoder)->options = (opts)))

declare function mad_decoder_run cdecl alias "mad_decoder_run" ( _
  byval lpDecoder    as mad_decoder ptr, _
  byval mode         as mad_decoder_mode) as integer

declare function mad_decoder_message cdecl alias "mad_decoder_message" ( _
  byval lpDecoder    as mad_decoder ptr , _
  byval lpAny        as any ptr , _
  byval lpInt        as integer ptr) as integer

#endif ' __MAD_BI__
