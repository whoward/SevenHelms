'  ###########
' # plug.bi #
'###########
' common to all plugout-XXX interfaces
#ifndef __FBS_PLUG_BI__
#define __FBS_PLUG_BI__
#include "fbstypes.bi"

type FBS_PLUG_t
  as any ptr           plug_hLib
  ' interface
  as function ()                         as string      plug_error
  as function (byref Plug as FBS_PLUG_t) as FBSBOOLEAN  plug_isany
  as function (byref Plug as FBS_PLUG_t) as FBSBOOLEAN  plug_init
  as function ()                         as FBSBOOLEAN  plug_start
  as function ()                         as FBSBOOLEAN  plug_stop
  as function ()                         as FBSBOOLEAN  plug_exit

  as any ptr           ThreadID
  as FBSBOOLEAN        ThreadExit
  as FILLCALLBACK      FillBuffer

  ' plublic section
  as zstring * 64      PlugName
  as zstring * 64      DeviceName
  as integer           Framesize
  as integer           nFrames
  as integer           nBuffers
  as integer           BufferSize
  as byte ptr          lpCurentBuffer '!!!
  as any ptr ptr       lpBuffers
  as FBS_FORMAT        Fmt
  as integer           index
end type
type FBS_PLUG          as FBS_PLUG_t

#endif ' __FBS_PLUG_BI__
