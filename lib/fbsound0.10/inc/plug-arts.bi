'  ################
' # plug-arts.bi #
'################

' _DS = declare sub
' _DF = declare function
' _B  = byval
' _R  = byref

type arts_stream_t as any ptr

' error codes 
#define ARTS_E_NOSERVER     ( -1 )
#define ARTS_E_NOBACKEND    ( -2 )
#define ARTS_E_NOSTREAM     ( -3 )
#define ARTS_E_NOINIT       ( -4 )
#define ARTS_E_NOIMPL       ( -5 )

' the values for stream parameters
' see arts_parameter_t
enum arts_parameter_t
  ARTS_P_BUFFER_SIZE     = 1
  ARTS_P_BUFFER_TIME     = 2
  ARTS_P_BUFFER_SPACE    = 3
  ARTS_P_SERVER_LATENCY  = 4
  ARTS_P_TOTAL_LATENCY   = 5
  ARTS_P_BLOCKING        = 6
  ARTS_P_PACKET_SIZE     = 7
  ARTS_P_PACKET_COUNT    = 8
  ARTS_P_PACKET_SETTINGS = 9
end enum

' parameters for streams
' ARTS_P_BUFFER_SIZE    (rw) bytes = (ARTS_P_PACKET_SIZE * ARTS_P_PACKET_COUNT)
' ARTS_P_BUFFER_TIME    (rw) ms
' ARTS_P_BUFFER_SPACE   (r ) bytes
' ARTS_P_SERVER_LATENCY (r ) ms
' ARTS_P_TOTAL_LATENCY  (r ) ms = (BUFFER_TIME + SERVER_LATENCY)
' ARTS_P_BLOCKING       (rw) 1 / 0
' ARTS_P_PACKET_SIZE    (r ) bytes
' ARTS_P_PACKET_COUNT   (r ) count
' ARTS_P_PACKET_SETTINGS(rw) uinteger &HCCCCSSSS Size=2^SSSS

' initializes the aRts C API, and connects to the sound server
' return 0 if everything is all right, an error code otherwise
_DF arts_init cdecl alias "arts_init" () as integer

' asks aRtsd to free the DSP device and 
' return 1 if it was successful, 
' return 0 if there were active non-suspendable modules
_DF arts_suspend cdecl alias "arts_suspend" () as integer

' asks aRtsd if the DSP device is free and 
' return 1 if it is, 0 if not
_DF arts_suspended cdecl alias "arts_suspended" () as integer

' converts an error code to a human readable error message
_DF arts_error_text cdecl alias "arts_error_text" ( _
_B errorcode as integer) as zstring ptr

' open a stream for playing 44100/22050 , 8/16, 1/2, "streamname"
_DF arts_play_stream cdecl alias "arts_play_stream" ( _
_B rate       as integer, _
_B bits       as integer, _
_B channels   as integer, _
_B streamname as string) as arts_stream_t

' open a stream for recording 44100/22050 , 8/16, 1/2, "streamname"
_DF arts_record_stream cdecl alias "arts_record_stream" ( _
_B rate       as integer, _
_B bits       as integer, _
_B channels   as integer, _
_B streamname as string) as arts_stream_t


#if 0
' read samples from stream
' returns number of read bytes on success or error code
_DF arts_read cdecl  alias "arts_read" ( _
_B stream   as arts_stream_t, _
_B lpBuffer _as any ptr      , _
_B count    as integer) as integer 
#endif

' write samples to to stream
' returns number of written bytes on success or error code
_DF arts_write cdecl alias "arts_write" ( _
_B stream   as arts_stream_t, _
_B lpBuffer as any ptr      , _
_B count    as integer) as integer 

' configure a parameter of a stream
' returns the new value of the parameter, or an error code
_DF arts_stream_set cdecl alias "arts_stream_set" ( _
_B stream as arts_stream_t, _
_B param  as arts_parameter_t, _
_B value  as integer) as integer

' query a parameter of a stream
' returns the value of the parameter, or an error code
_DF arts_stream_get cdecl alias "arts_stream_get" ( _
_B stream as arts_stream_t, _
_B param  as arts_parameter_t) as integer

' close a stream
_DS arts_close_stream cdecl alias "arts_close_stream" ( _
_B stream as arts_stream_t)

' disconnects from the sound server and frees the aRts C API internals
_DS arts_free cdecl alias "arts_free" ()
