'  #############
' # mmncpu.bi #
'#############
' Copyright 2006,2007 D.J.Peters (Joshy)
' d.j.peters@web.de
' http://fsr.sf.net/forum
#ifndef __MMNCPU_BI__
#define __MMNCPU_BI__

#include "fbstypes.bi"

#ifdef __FB_WIN32__
# inclib "fbscpuwin"
#else
# inclib "fbscpulin"
#endif

' _DS = declare sub
' _DF = declare function
' _B  = byval
' _AAP = as any ptr
' _AAPP = as any ptr ptr
#define _AAP as any ptr
#define _AAPP as any ptr ptr

_DF IsFPU              () as FBSBOOLEAN
_DF IsTSC              () as FBSBOOLEAN
_DF IsCMOV             () as FBSBOOLEAN
_DF IsMMX              () as FBSBOOLEAN
_DF IsMMX2             () as FBSBOOLEAN
_DF IsSSE              () as FBSBOOLEAN
_DF IsSSE2             () as FBSBOOLEAN
_DF IsNOW3D            () as FBSBOOLEAN
_DF IsNOW3D2           () as FBSBOOLEAN
_DF Mhz                () as integer
_DF CPUCounter         () as longint

_DS Zero               (_B d _AAP,                                                           _B n as integer)
_DS ZeroBuffer         (_B s _AAP,_B p _AAPP,_B e _AAP ,                                     _B n as integer)
_DS Copy               (_B d _AAP,_B s _AAP ,                                                _B n as integer)
_DS Mix16              (_B d _AAP,_B a _AAP ,_B b _AAP ,                                     _B n as integer)
_DS Scale16            (_B d _AAP,_B s _AAP ,_B v  as single,                                _B n as integer)
_DS Pan16              (_B d _AAP,_B s _AAP ,_B l  as single,_B r as single,                 _B n as integer)
_DS CopyRight16        (_B d _AAP,_B s _AAP ,_B p _AAPP,_B e _AAP ,_B l _AAPP,               _B n as integer)
_DS CopyRight32        (_B d _AAP,_B s _AAP ,_B p _AAPP,_B e _AAP ,_B l _AAPP,               _B n as integer)
_DS MoveRight16        (_B s _AAP,_B p _AAPP,_B e _AAP ,_B l _AAPP,                          _B n as integer)
_DS MoveRight32        (_B s _AAP,_B p _AAPP,_B e _AAP ,_B l _AAPP,                          _B n as integer)
_DS CopySliceRight16   (_B d _AAP,_B s _AAP ,_B p _AAPP,_B e _AAP ,_B l _AAPP,_B v as single,_B n as integer)
_DS CopySliceRight32   (_B d _AAP,_B s _AAP ,_B p _AAPP,_B e _AAP ,_B l _AAPP,_B v as single,_B n as integer)
_DS MoveSliceRight16   (_B s _AAP,_B p _AAPP,_B e _AAP ,_B l _AAPP,_B v as single,           _B n as integer)
_DS MoveSliceRight32   (_B s _AAP,_B p _AAPP,_B e _AAP ,_B l _AAPP,_B v as single,           _B n as integer)
_DS CopySliceLeft16    (_B d _AAP,_B s _AAP ,_B p _AAPP,_B e _AAP ,_B l _AAPP,_B v as single,_B n as integer)
_DS CopySliceLeft32    (_B d _AAP,_B s _AAP ,_B p _AAPP,_B e _AAP ,_B l _AAPP,_B v as single,_B n as integer)
_DS MoveSliceLeft16    (_B s _AAP,_B p _AAPP,_B e _AAP ,_B l _AAPP,_B v as single,           _B n as integer)
_DS MoveSliceLeft32    (_B s _AAP,_B p _AAPP,_B e _AAP ,_B l _AAPP,_B v as single,           _B n as integer)
_DS CopyMP3Frame       (_B s _AAP,_B p _AAPP,_B e _AAP ,_B f _AAP ,                          _B n as integer)
_DS CopySliceMP3Frame32(_B s _AAP,_B p _AAPP,_B e _AAP ,_B f _AAP ,_B v as single,           _B n as integer)
_DS CopySliceMP3Frame16(_B s _AAP,_B p _AAPP,_B e _AAP ,_B f _AAP ,_B v as single,           _B n as integer)
_DS ScaleMP3Frame_22_16(_B d _AAP,_B a _AAP ,_B b _AAP ,                                     _B n as integer)
_DS ScaleMP3Frame_21_16(_B d _AAP,_B a _AAP ,_B b _AAP ,                                     _B n as integer)
_DS ScaleMP3Frame_12_16(_B d _AAP,_B s _AAP ,                                                _B n as integer)
_DS ScaleMP3Frame_11_16(_B d _AAP,_B s _AAP ,                                                _B n as integer)

#endif ' __MMNCPU_BI__