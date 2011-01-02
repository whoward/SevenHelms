' vorbisfile.bi
#ifndef __VORBISFILE__
#define __VORBISFILE__

#ifdef __FB_WIN32__
  #inclib "oggwin"
  #inclib "vorbiswin"
  #inclib "vorbisfilewin"
#else
# ifdef __FB_LINUX__
    #inclib "ogg"
    #inclib "vorbis"
    #inclib "vorbisfile"
# else
#  error target must be WIN32 or Linux x86 !
# endif
#endif

#define OV_FALSE      -1
#define OV_EOF        -2
#define OV_HOLE       -3

#define OV_EREAD      -128
#define OV_EFAULT     -129
#define OV_EIMPL      -130
#define OV_EINVAL     -131
#define OV_ENOTVORBIS -132
#define OV_EBADHEADER -133
#define OV_EVERSION   -134
#define OV_ENOTAUDIO  -135
#define OV_EBADPACKET -136
#define OV_EBADLINK   -137
#define OV_ENOSEEK    -138

type vorbis_info
  as integer version
  as integer channels
  as integer rate
  as integer bitrate_upper
  as integer bitrate_nominal
  as integer bitrate_lower
  as integer bitrate_window
  as any ptr codec_setup
end type

type vorbis_dsp_state
  as integer           analysisp
  as vorbis_info ptr   vi

  as single ptr ptr    pcm
  as single ptr ptr    pcmret
  as integer           pcm_storage
  as integer           pcm_current
  as integer           pcm_returned

  as integer           preextrapolate
  as integer           eofflag

  as integer           lW
  as integer           W
  as integer           nW
  as integer           centerW

  as longint           granulepos
  as longint           sequence

  as longint           glue_bits
  as longint           time_bits
  as longint           floor_bits
  as longint           res_bits

  as any ptr           backend_state
end type
type vorbis_comment
  ' unlimited user comment fields.  libvorbis writes 'libvorbis'
  ' whatever vendor is set to in encode
  as zstring ptr ptr user_comments
  as integer ptr     comment_lengths
  as integer         comments
  as zstring ptr     vendor
end type
type ogg_stream_state
  as ubyte ptr         body_data     ' bytes from packet bodies
  as integer           body_storage  ' storage elements allocated
  as integer           body_fill     ' elements stored; fill mark
  as integer           body_returned ' elements of fill returned

  as integer ptr      lacing_vals    ' The values that will go to the segment table
  as longint ptr      granule_vals   ' granulepos values for headers. Not compact
                                     ' this way, but it is simple coupled to the lacing fifo
  as integer          lacing_storage
  as integer          lacing_fill
  as integer          lacing_packet
  as integer          lacing_returned

  as ubyte            header(282-1)   ' working space for header encode
  as integer          header_fill
  as integer e_o_s ' set when we have buffered the last packet in the logical bitstream
  as integer b_o_s ' set after we've written the initial page of a logical bitstream
  as integer          serialno
  as integer          pageno
  as longint         packetno 
  ' sequence number for decode; the framing knows where there's a hole in the data,
  ' but we need coupling so that the codec (which is in a seperate abstraction layer)
  ' also knows about the gap
  as longint          granulepos
end type
type oggpack_buffer
  as integer          endbyte
  as integer          endbit
  as ubyte ptr        buffer
  as ubyte ptr        pchar
  as integer          storage
end type

type ogg_sync_state
  as ubyte ptr        pData
  as integer          storage
  as integer          fill
  as integer          returned
  as integer          unsynced
  as integer          headerbytes
  as integer          bodybytes
end type
type alloc_chain
  as any ptr          pPtr
  as alloc_chain ptr pNext
end type
type vorbis_block
  ' necessary stream state for linking to the framing abstraction
  as single ptr ptr   pcm ' this is a pointer into local storage
  as oggpack_buffer   opb

  as integer          lW
  as integer          W
  as integer          nW
  as integer          pcmend
  as integer          mode

  as integer          eofflag
  as longint          granulepos
  as longint          sequence
  as vorbis_dsp_state ptr vd ' For read-only access of configuration

  ' local storage to avoid remallocing; it's up to the mapping to structure it
  as any ptr          localstore
  as integer          localtop
  as integer          localalloc
  as integer          totaluse
  as alloc_chain ptr  reap

  ' bitmetrics for the frame
  as integer          glue_bits
  as integer          time_bits
  as integer          floor_bits
  as integer          res_bits

  as any ptr          internal
end type

type ov_callbacks
  read_func  as function CDECL (pAny as any ptr,size as integer,nmemb as integer,pUser as any ptr) as integer
  seek_func  as function CDECL (pUser as any ptr,offset as longint,whence as integer) as integer
  close_func as function CDECL (pUser as any ptr) as integer
  tell_func  as function CDECL (pUser as any ptr) as integer
end type

type OggVorbis_File
  as any ptr           datasource
  as integer           seekable
  as longint           offset64
  as longint           end64
  as ogg_sync_state    oy

  ' If the FILE handle isn't seekable (eg, a pipe), only the current stream appears
  as integer           links
  as longint ptr       offsets
  as longint ptr       dataoffsets
  as integer           serialnos
  as longint ptr       pcmlengths ' overloaded to maintain binary
                                  ' compatability; x2 size, stores both
                                  ' beginning and end values
  as vorbis_info ptr    vi
  as vorbis_comment ptr vc

  ' Decoding working state local storage
  as longint           pcm_offset
  as integer           ready_state
  as integer           current_serialno
  as integer           current_link

  as double            bittrack
  as double            samptrack

  as ogg_stream_state  os ' take physical pages, weld into a logical stream of packets
  as vorbis_dsp_state  vd ' central working state for the packet->PCM decoder
  as vorbis_block      vb ' local working space for packet->PCM decode
  as ov_callbacks      callbacks 
end type

function OGGErrorString(code as integer) as string
  select case (code)
    case OV_EREAD:       return "Read from media."
    case OV_ENOTVORBIS:  return "Not Vorbis data."
    case OV_EVERSION:    return "Vorbis version mismatch."
    case OV_EBADHEADER:  return "Invalid Vorbis header."
    case OV_EFAULT:      return "Internal logic fault (bug or heap/stack corruption."
    case else:           return "Unknown Ogg error."
  end select
end function

#define DF(n) declare function n cdecl alias #n 
DF(ov_clear) (vf as OggVorbis_File ptr) as integer 
DF(ov_fopen) (path as zstring ptr,vf as OggVorbis_File ptr) as integer
DF(ov_open) (pFILE as any ptr,vf as OggVorbis_File ptr,initial as ubyte ptr,ibytes as integer) as integer
DF(ov_open_callbacks) (datasource as any ptr, _
                       vf as OggVorbis_File ptr, _
                       initial as ubyte ptr, _
                       ibytes as integer, _
                       byval cb as ov_callbacks)  as integer

DF(ov_test) (pFile as any ptr,vf as OggVorbis_File ptr,initial as ubyte ptr,ibytes as integer) as integer
DF(ov_test_callbacks) (datasource as any ptr, vf as OggVorbis_File ptr,initial as ubyte ptr, ibytes as integer,byval cb as ov_callbacks) as integer
DF(ov_test_open) (vf as OggVorbis_File ptr) as integer

DF(ov_bitrate) (vf as OggVorbis_File ptr,i as integer ) as integer
DF(ov_bitrate_instant) (vf as OggVorbis_File ptr) as integer
DF(ov_streams) (vf as OggVorbis_File ptr) as integer
DF(ov_seekable) (vf as OggVorbis_File ptr) as integer
DF(ov_serialnumber) (vf as OggVorbis_File ptr,i as integer ) as integer

DF(ov_raw_total) (vf as OggVorbis_File ptr,i as integer ) as longint
DF(ov_pcm_total) (vf as OggVorbis_File ptr,i as integer ) as longint
DF(ov_time_total) (vf as OggVorbis_File ptr,i as integer ) as double

DF(ov_raw_seek) (vf as OggVorbis_File ptr,pos as longint)  as integer
DF(ov_pcm_seek) (vf as OggVorbis_File ptr,pos as longint) as integer
DF(ov_pcm_seek_page) (vf as OggVorbis_File ptr,pos as longint) as integer
DF(ov_time_seek) (vf as OggVorbis_File ptr,pos as double) as integer
DF(ov_time_seek_page) (vf as OggVorbis_File ptr,pos as double) as integer

DF(ov_raw_seek_lap) (vf as OggVorbis_File ptr,pos as longint) as integer
DF(ov_pcm_seek_lap) (vf as OggVorbis_File ptr,pos as longint) as integer
DF(ov_pcm_seek_page_lap) (vf as OggVorbis_File ptr,pos as longint) as integer
DF(ov_time_seek_lap) (vf as OggVorbis_File ptr,pos as double) as integer
DF(ov_time_seek_page_lap) (vf as OggVorbis_File ptr,pos as double) as integer

DF(ov_raw_tell) (vf as OggVorbis_File ptr) as longint
DF(ov_pcm_tell) (vf as OggVorbis_File ptr) as longint
DF(ov_time_tell) (vf as OggVorbis_File ptr) as double

DF(ov_info) (vf as OggVorbis_File ptr,link as integer) as vorbis_info ptr
DF(ov_comment) (vf as OggVorbis_File ptr,link as integer) as vorbis_comment ptr

DF(ov_read_float) (vf as OggVorbis_File ptr,pcm_channels as single ptr ptr ptr,samples as integer, bitstream as integer ptr) as integer
DF(ov_read) (vf as OggVorbis_File ptr,buffer as ubyte ptr,length as integer,bigendianp as integer,word as integer,sgned as integer,bitstream as integer ptr) as integer
DF(ov_crosslap) (vf as OggVorbis_File ptr,vf2 as OggVorbis_File ptr) as integer

DF(ov_halfrate) (vf as OggVorbis_File ptr,flag as integer) as integer
DF(ov_halfrate_p) (vf as OggVorbis_File ptr) as integer

#endif ' __VORBISFILE__