'  #############
' # fbsdsp.bi #
'#############

#ifndef __FBS_DSP_BI__
#define __FBS_DSP_BI__

' _DS = declare sub
' _DF = declare function
' _B  = byval
' _R  = byref

const PI         as single = 3.141592654f
const PI2        as single = 2.0f * PI
const rad2deg    as single = 180.0/PI
const deg2rad    as single = PI/180.0

#define MAX_FILTERS 10
type FBS_FILTER
  as integer enabled,inuse
  as single  Center,Rate,Octave,dB,Scale
  as single  a1,a2,b0,b1,b2
  as single  x1_l,x2_l,y1_l,y2_l
  as single  x1_r,x2_r,y1_r,y2_r
end type

const _Center = offsetof(FBS_FILTER,Center)
const _Octave = offsetof(FBS_FILTER,Octave)
const _dB     = offsetof(FBS_FILTER,dB)
'const _Scale = offsetof(FBS_FILTER,Scale)
const _a1     = offsetof(FBS_FILTER,a1)
const _a2     = offsetof(FBS_FILTER,a2)
const _b0     = offsetof(FBS_FILTER,b0)
const _b1     = offsetof(FBS_FILTER,b1)
const _b2     = offsetof(FBS_FILTER,b2)

const _x1_l   = offsetof(FBS_FILTER,x1_l)
const _x2_l   = offsetof(FBS_FILTER,x2_l)
const _y1_l   = offsetof(FBS_FILTER,y1_l)
const _y2_l   = offsetof(FBS_FILTER,y2_l)

const _x1_r   = offsetof(FBS_FILTER,x1_r)
const _x2_r   = offsetof(FBS_FILTER,x2_r)
const _y1_r   = offsetof(FBS_FILTER,y1_r)
const _y2_r   = offsetof(FBS_FILTER,y2_r)

_DF fbs_Rad2Deg     (_B as double) as double
_DF fbs_Deg2Rad     (_B as double) as double
_DF fbs_Volume_2_DB (_B as single) as single
_DF fbs_DB_2_Volume (_B as single) as single 
_DF fbs_Pow         (_B as double, _B as double) as double

_DS _PitchShiftMono_asm( _
  _B d as short ptr, _
  _B s as short ptr, _
  _B v as single  , _
  _B r as single  , _
  _B n as integer)

_DS _PitchShiftStereo_asm( _
  _B d as short ptr, _
  _B s as short ptr, _
  _B v as single  , _
  _B r as single  , _
  _B n as integer)

_DS _Set_EQFilter(_B lpFilter as fbs_filter ptr, _
                  _B Center   as single       , _
                  _B dB       as single = 0.0 , _
                  _B Octave   as single = 1.0 , _
                  _B Rate     as single = 44100.0)
_DS _Filter_Mono_asm16  (_B as any ptr,_B as any ptr,_B as fbs_filter ptr,_B as integer)
_DS _Filter_Stereo_asm16(_B as any ptr,_B as any ptr,_B as fbs_filter ptr,_B as integer)

#endif ' __FBS_DSP_BI__