'  ###############
' # fbstypes.bi #
'###############
#ifndef __FBS_TYPES_BI__
#define __FBS_TYPES_BI__

'#define DEBUG

#ifdef DEBUG
# define dprint(msg) open err for output as #99:print #99,"debug: " & msg:close #99
#else
# define dprint(msg):
#endif

#ifndef NULL
# define NULL 0
#endif

#define _DF declare function
#define _DS declare sub
#define _B byval
#define _R byref


#ifndef false
# define false 0
#endif
#ifndef true
# define true 1
#endif

type FBSBOOLEAN as integer

const _WAVE_FORMAT_PCM as short = 1
type _PCM_WAVEFORMAT
  as short    wFormatTag ' = WAVE_FORMAT_PCM
  as short    nChannels
  as integer  nRate
  as integer  nBytesPerSec
  as short    Framesize
  as short    nBits
end type
const _PCM_WAVEFORMAT_SIZE as integer  = 16

enum VCCs
  _RIFF = &H46464952
  _WAVE = &H45564157
  _fmt  = &H20746D66
  _data = &H61746164
end enum

type _PCM_FILE_HDR field = 1
  ChunkRIFF         as integer  ' 4       Chunktype   'RIFF'
  ChunkRIFFSize     as integer  ' 8       ChunkSize
  ChunkID           as integer  '12       ChunkID     'WAVE'
  Chunkfmt          as integer  '16       Chunktype   'fmt '
  ChunkfmtSize      as integer  '20       ChunkSize

    wFormatTag      as short    '22  2
    nChannels       as short    '24  4
    nRate           as integer  '28  8
    nBytesPerSec    as integer  '32 12
    Framesize       as short    '34 14
    nBits           as short    '36 16

  Chunkdata         as integer  '40       Chunktype   'data'
  ChunkdataSize     as integer  '44       ChunkSize
end type
const _PCM_FILE_HDR_SIZE = 44
const _PCM_FMT_SIZE      = 16

type FBS_FORMAT_t
  as integer    nRate
  as integer    nBits
  as integer    nChannels
  as fbsboolean signed
end type
type FBS_FORMAT as FBS_FORMAT_t

type FBS_WAVE_t
  as byte ptr lpStart
  as integer   nBytes
end type
type FBS_WAVE as FBS_WAVE_t

type FBS_SAMPLE    as short
type MONO_SAMPLE   as FBS_SAMPLE
type STEREO_SAMPLE field=1
  as MONO_SAMPLE   l,r
end type

type FillCallback       as sub (byval lpArgs    as integer)
type FBS_BUFFERCALLBACK as sub (byval lpSamples as FBS_SAMPLE ptr, _
                                byval nChannels as integer       , _
                                byval nSamples  as integer)

type FBS_SOUND_t
  as FBS_BUFFERCALLBACK  Callback
  as FBSBOOLEAN          EnabledCallback
  as integer ptr         lphSound
  as byte ptr            lpStart
  as byte ptr            lpPlay
  as byte ptr            lpEnd
  as byte ptr            lpUserStart
  as byte ptr            lpUserEnd
  as byte ptr            lpOrg
  as byte ptr            lpBuf
  as integer             nLoops
  as single              Speed
  as single              Volume
  as single              Pan
  as single              lVolume
  as single              rVolume
  as fbsboolean          usercontrol
  as fbsboolean          muted
  as fbsboolean          paused
end type
type FBS_SOUND as FBS_SOUND_t

enum FBS_KEYCODES
  k_none            =   0 
  Ctrl_A            =   1 
  Ctrl_B            =   2 
  Ctrl_C            =   3 
  Ctrl_D            =   4 
  Ctrl_E            =   5 
  Ctrl_F            =   6 
  k_bell            =   7 
  k_backspace       =   8 
  k_tab             =   9 
  Ctrl_J            =  10 
  Ctrl_K            =  11 
  Ctrl_L            =  12 
  k_enter           =  13 
  Ctrl_N            =  14 
  Ctrl_O            =  15 
  Ctrl_P            =  16 
  Ctrl_Q            =  17 
  Ctrl_R            =  18 
  Ctrl_S            =  19 
  Ctrl_T            =  20 
  Ctrl_U            =  21 
  Ctrl_V            =  22 
  Ctrl_W            =  23 
  Ctrl_X            =  24 
  Ctrl_Y            =  25 
  Ctrl_Z            =  26 
  k_escape          =  27 
  Ctrl_5            =  29 
  Ctrl_6            =  30 
  Ctrl_7            =  31 
  k_space           =  32
  k_exclamationmark =  33 ' ! 
  k_quote           =  34
  k_hash            =  35 ' # 
  k_dollar          =  36 ' $ 
  k_percent         =  37 ' % 
  k_ampersand       =  38 ' & 
  k_singlequote     =  39 ' ' 
  k_leftbracket     =  40 ' ( 
  k_rightbracket    =  41 ' ) 
  k_multiply        =  42 ' * 
  k_plus            =  43 ' + 
  k_comma           =  44 ' , 
  k_minus           =  45 ' - 
  K_period          =  46 ' . 
  k_slash           =  47 ' / 

  k_0               =  48 
  k_1               =  49 
  k_2               =  50 
  k_3               =  51 
  k_4               =  52 
  k_5               =  53 
  k_6               =  54 
  k_7               =  55 
  k_8               =  56 
  k_9               =  57 

  k_colon           =  58 ' : 
  k_semicolon       =  59 ' ; 
  k_less            =  60 ' < 
  k_equals          =  61 ' = 
  k_greater         =  62 ' > 
  Shift_questionmark=  63 ' ? 
  AltGr_Q           =  64 ' @ 

  Shift_A           =  65 
  Shift_B           =  66 
  Shift_C           =  67 
  Shift_D           =  68 
  Shift_E           =  69 
  Shift_F           =  70 
  Shift_G           =  71 
  Shift_H           =  72 
  Shift_I           =  73 
  Shift_J           =  74 
  Shift_K           =  75 
  Shift_L           =  76 
  Shift_M           =  77 
  Shift_N           =  78 
  Shift_O           =  79 
  Shift_P           =  80 
  Shift_Q           =  81 
  Shift_R           =  82 
  Shift_S           =  83 
  Shift_T           =  84 
  Shift_U           =  85 
  Shift_V           =  86 
  Shift_W           =  87 
  Shift_X           =  88 
  Shift_Y           =  89 
  Shift_Z           =  90 

  k_L_square_bracket=  91 ' [ 
  k_Backslash       =  92 ' \ 
  k_R_square_bracket=  93 ' ] 
  k_Caret           =  94 ' ^ 
  k_underscore      =  95 ' _ 

  k_A               =  97 
  k_B               =  98 
  k_C               =  99 
  k_D               = 100 
  k_E               = 101 
  k_F               = 102 
  k_G               = 103 
  k_H               = 104 
  k_I               = 105 
  k_J               = 106 
  k_K               = 107 
  k_L               = 108 
  k_M               = 109 
  k_N               = 110 
  k_O               = 111 
  k_P               = 112 
  k_Q               = 113 
  k_R               = 114 
  k_S               = 115 
  k_T               = 116 
  k_U               = 117 
  k_V               = 118 
  k_W               = 119 
  k_X               = 120 
  k_Y               = 121 
  k_Z               = 122 
  k_L_curly_bracket = 123 ' { 
  k_R_curly_bracket = 125 ' } 
  k_Tilde           = 126 ' ~ 
  AltGr_C           = 162 ' ¢ 
  AltGr_E           = 164 ' (€) 
  AltGr_Y           = 171 ' « 
  AltGr_6           = 172 
  AltGr_2           = 178 ' ² 
  AltGr_3           = 179 ' ³ 
  AltGr_M           = 181 ' µ 
  AltGr_R           = 182 
  AltGr_dot         = 183 ' · 
  AltGr_1           = 185 ' ¹ 
  AltGr_X           = 187 ' » 
  Shift_ae          = 196 ' Ä 
  Shift_oe          = 214 ' Ö 
  Shift_ue          = 220 ' Ü 
  k_ss              = 223 ' ß 
  k_ae              = 228 ' ä 
  AltGr_A           = 230 ' æ 

  AltGr_D           = 240 ' ð 
  k_oe              = 246 ' ö 
  AltGr_O           = 248 ' ø 
  k_ue              = 252 ' ü 
  AltGr_P           = 254 ' þ 

  k_f1              = 315
  k_f2              = 316
  k_f3              = 317
  k_f4              = 318
  k_f5              = 319
  k_f6              = 320
  k_f7              = 321
  k_f8              = 322
  k_f9              = 323
  k_f10             = 324

  k_home            = 327
  K_up              = 328
  k_pageup          = 329

  k_left            = 331

  k_right           = 333

  k_end             = 335
  k_down            = 336
  k_pagedown        = 337
  k_insert          = 338
  k_delete          = 339

  K_WINDOW_CLOSE    = 363
end enum

#endif ' __FBS_TYPES_BI__
