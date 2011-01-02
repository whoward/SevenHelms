'  ###############
' # fbsound.bas #
'###############
' copyright D.J.Peters (Joshy)
' d.j.peters@web.de

#include "fbsound.bi"
#include "plug.bi"
#include "vorbisfile.bi"
#include "fbsdsp.bas"

type mix_t                 as sub(_B as any ptr  ,_B as any ptr    ,_B as any ptr    ,_B as integer)
type scale_t               as sub(_B as any ptr  ,_B as any ptr    ,_B as single     ,_B as integer)
type pan_t                 as sub(_B as any ptr  ,_B as any ptr    ,_B as single     ,_B as single     ,_B as integer)
type copyright_t           as sub(_B as any ptr  ,_B as any ptr    ,_B as any ptr ptr,_B as any ptr    ,_B as any ptr ptr,_B as integer)
type moveright_t           as sub(_B as any ptr  ,_B as any ptr ptr,_B as any ptr    ,_B as any ptr ptr,_B as integer)
type copysliceright_t      as sub(_B as any ptr  ,_B as any ptr    ,_B as any ptr ptr,_B as any ptr    ,_B as any ptr ptr,_B as single ,_B as integer)
type movesliceright_t      as sub(_B as any ptr  ,_B as any ptr ptr,_B as any ptr    ,_B as any ptr ptr,_B as single     ,_B as integer)
type copysliceleft_t       as sub(_B as any ptr  ,_B as any ptr    ,_B as any ptr ptr,_B as any ptr    ,_B as any ptr ptr,_B as single ,_B as integer)
type movesliceleft_t       as sub(_B as any ptr  ,_B as any ptr ptr,_B as any ptr    ,_B as any ptr ptr,_B as single     ,_B as integer)
type CopyMP3Frame_t        as sub(_B as any ptr  ,_B as any ptr ptr,_B as any ptr    ,_B as any ptr    ,_B as integer)
type CopySliceMP3Frame_t   as sub(_B as any ptr  ,_B as any ptr ptr,_B as any ptr    ,_B as any ptr    ,_B as single     ,_B as integer)
type ScaleMP3FrameStereo_t as sub(_B as any ptr  ,_B as any ptr    ,_B as any ptr    ,_B as integer)
type ScaleMP3FrameMono_t   as sub(_B as any ptr  ,_B as any ptr    ,_B as integer)
type Filter_t              as sub(_B as any ptr  ,_B as any ptr    ,_B as fbs_filter ptr,_B as integer)
type PitchShift_t          as sub(_B as short ptr,_B as short ptr  ,_B as single     ,_B as single     ,_B as integer)

type FBS_STREAM_T
  as FBS_STREAM_TYPES  StreamType
  as fbsboolean        InUse
  as fbsboolean        IsStreaming
  as fbsboolean        IsFin
  as fbs_filter        Filters(MAX_FILTERS-1) ' !!!
  as fbsboolean        EnabledCallback
  as fbs_buffercallback  Callback

  as short ptr         p16,lpStreamSamples
  as single            l,r,scale,nPos
  as integer           nSamplesTarget,nBytesTarget,nRest
  as single            Volume
  as single            Pan
  as single            lVolume
  as single            rVolume

  as FBS_FORMAT        fmt
  as integer           i
  as any ptr           hThread,lpBuf
  as integer ptr       lphStream,lp32L,lp32R
  as ubyte ptr         lpStart,lpPlay,lpEnd ',lpOut
  as short ptr         lpFill
  as integer           RetStatus
  as mad_stream        mStream
  as mad_frame         mFrame
  as mad_synth         mSynth
  as ubyte ptr         lpInArray
  as ubyte ptr         GuardPTR
  as integer            nReadSize,nReadRest,nDecodedSize
  as ubyte ptr         lpRead
  as integer            hFile,nFrames,nBytes,nInSize,nOutSize,nOuts
end type
type FBS_STREAM as FBS_STREAM_t

dim shared _mix                 as mix_t
dim shared _scale               as scale_t
dim shared _pan                 as pan_t
dim shared _copyright           as copyright_t
dim shared _moveright           as moveright_t
dim shared _copysliceright      as copysliceright_t
dim shared _movesliceright      as movesliceright_t
dim shared _copysliceleft       as copysliceleft_t
dim shared _movesliceleft       as movesliceleft_t

dim shared _CopyMP3Frame        as CopyMP3Frame_t
dim shared _CopySliceMP3Frame   as CopySliceMP3Frame_t
dim shared _ScaleMP3FrameStereo as ScaleMP3FrameStereo_t
dim shared _ScaleMP3FrameMono   as ScaleMP3FrameMono_t
dim shared _PitchShift          as PitchShift_t
dim shared _Filter              as Filter_t

dim shared _Sounds()            as FBS_SOUND
dim shared _nSounds             as integer
dim shared _Waves()             as FBS_WAVE
dim shared _nWaves              as integer

dim shared _MP3Stream           as FBS_STREAM

dim shared _PlugPath            as string
dim shared _Plugs()             as FBS_Plug
dim shared _nPlugs              as integer
dim shared _Plug                as integer
dim shared _IsRunning           as fbsboolean
dim shared _IsInit              as fbsboolean
dim shared _nPlayingSounds      as integer
dim shared _nPlayingStreams     as integer
dim shared _nPlayedbytes        as integer
dim shared _EnabledCallback     as fbsboolean
dim shared _MasterCallback      as fbs_buffercallback
dim shared _MasterBuffer        as any ptr
dim shared _MasterVolume        as single
dim shared _MaxChannels         as integer
dim shared _seed                as integer

dim shared _MasterFilters(MAX_FILTERS-1) as fbs_filter

function fbs_Get_KeyCode() As FBS_KEYCODES export
  dim as string  key=inkey() 
  dim as integer keycode=len(key)
  If keycode Then
    keycode-=1
    keycode=key[keycode]+(keycode shl 8)
  End If
  Return keycode
end function


function FBS_Get_PlugPath() as string export
  return _PlugPath
end function

sub FBS_Set_PlugPath(_B NewPath as string) export
  _PlugPath=NewPath
end sub

function FBS_Get_MaxChannels(_B lpMaxChannels as integer ptr) as fbsboolean export
  if lpMaxChannels=NULL then return false
  *lpMaxChannels=_MaxChannels
  return true
end function

function FBS_Set_MaxChannels(_B MaxChannels as integer) as fbsboolean export
  if MaxChannels<1   then MaxChannels=  1
  if MaxChannels>256 then MaxChannels=256
  _MaxChannels=MaxChannels
  return true
end function

function _IshFilter(_B hFilter as integer) as fbsboolean
  if (_IsInit=false)                       then return false  
  if (hFilter<0) or (hFilter>=MAX_FILTERS) then return false  
   return true
end function

function FBS_Set_MasterFilter(_B nFilter as integer, _
                              _B Center  as single, _
                              _B dB      as single, _
                              _B Octave  as single = 1.0, _
                              _B OnOff   as fbsboolean=True) as fbsboolean export

  if _IshFilter(nFilter)=false then return false  
  _Set_EQFilter(@_MasterFilters(nFilter), _
                Center, _
                db, _
                octave, _
                _Plugs(_Plug).fmt.nRate)

  _MasterFilters(nFilter).Enabled=OnOff
   return true
end function

function FBS_Enable_MasterFilter (_B nFilter as integer) as fbsboolean export
  if _IshFilter(nFilter)=false then return false
  _MasterFilters(nFilter).Enabled=True
   return true
end function

function FBS_Disable_MasterFilter (_B nFilter as integer) as fbsboolean export
  if _IshFilter(nFilter)=false then return false
  _MasterFilters(nFilter).Enabled=False
   return true
end function

sub _MIXER(_B lpOChannels as any ptr, _
           _B lpIChannels as any ptr ptr, _
           _B nChannels   as integer , _
           _B nBytes      as integer )
  dim as integer i
  if nChannels<2 then
    dprint("mixer chn<2")
    exit sub
  end if

  _mix(lpOChannels, _
       lpIChannels[0], _
       lpIChannels[1], _
         nBytes)
  if nChannels=2 then exit sub

  for i=2 to nChannels-1
    _mix(lpOChannels   , _
         lpOChannels   , _
         lpIChannels[i], _
         nBytes)
  next
end sub

function FBS_Set_MasterVolume(_B Volume as single) as fbsboolean export
  if (_ISInit=false) then return false
  if (Volume<0.001 ) then Volume=0.0
  if (Volume>2.0   ) then Volume=2.0
  _MasterVolume=Volume
  return true
end function

function FBS_Get_MasterVolume(_B lpVolume as single ptr) as fbsboolean export
  if _ISInit=false then return false
  *lpVolume=_MasterVolume
  return true
end function

sub FBS_PitchShift(_B d as short ptr, _
                   _B s as short ptr, _
                   _B v as single   , _
                   _B n as integer  ) export
  if (_ISInit=false) then exit sub
  _PitchShift(d,s,v,fbs_Get_PlugRate(),n)
end sub



' called from playback device
private _
sub _FillBuffer(_B lpArg as integer)
  dim as any ptr MixerChannels(256)
  dim as FBS_Plug PTR plug
  dim as integer i,j,k,nSize,nBytes,rest
  dim as integer nPlayingSounds,nPlayingStreams,nChannels

  ' convert to Plugout format
  Plug=cptr(FBS_Plug PTR,lpArg)

  'that should never happen
  if (Plug                =NULL) then exit sub
  if (Plug->lpCurentBuffer=NULL) then exit sub
  if (Plug->Buffersize    <   4) then exit sub

  _Masterbuffer =Plug->lpCurentBuffer
  _nPlayedBytes+=Plug->Buffersize

  if _MP3Stream.InUse=true then
    with _MP3Stream
      if (.InUse=true) then
        if (.nOuts>0) then nPlayingStreams+=1
        ' enought decoded datas aviable
        if (.nOuts>=Plug->Buffersize) then
          if (.lpPlay+Plug->Buffersize)<=.lpEnd then
            ' nothing
            if (.Volume=0.0) then
              zero(.lpBuf,Plug->Buffersize)
            else
              if (.Volume<>1.0) then _scale(.lpPlay,.lpPlay,.Volume,Plug->Buffersize)
              if (Plug->Fmt.nChannels=2) and (.pan<>0.0) then
                _pan(.lpBuf,.lpPlay,.lVolume,.rVolume,Plug->Buffersize)
              else
                copy(.lpBuf,.lpPlay,Plug->Buffersize)
              end if
            end if
            .nOuts-=Plug->Buffersize
            MixerChannels(nChannels)=.lpBuf
            if (.Callback<>NULL) and (.EnabledCallback=true) then
              .Callback( cptr(short ptr,.lpBuf), _
                        Plug->FMT.nChannels   , _
                        Plug->Buffersize shr Plug->FMT.nChannels)
            end if
            .lpPlay+=Plug->Buffersize
            if (.lpPlay>=.lpEnd) then .lpPlay=.lpStart
            nChannels+=1
            if .nOuts=0 and .IsStreaming=false then .InUse=False
          end if
        else
          if (.nOuts=0) and (.IsStreaming=false) then 
            '.InUse=false
          end if 
        end if
      else
         dprint(".InUse=False")
      end if
    end with
  end if

  if (_nWaves > 0) and (_nSounds > 0) then
    ' how many playing sounds
    for i=0 to _nSounds-1
      if (_Sounds(i).lpStart<>NULL) and _
         (_Sounds(i).lpBuf  <>NULL) and _ 
         (_Sounds(i).nLoops > 0   ) and _
         (_Sounds(i).Paused =false) then nPlayingSounds+=1
    next
  end if

  _nPlayingSounds =nPlayingSounds
  _nPlayingStreams=nPlayingStreams

  ' nothing or only one stream are playing?
if (nPlayingSounds>0) then

  for i=0 to _nSounds-1
    ' is sound active ?
    if (_Sounds(i).lpStart<>NULL ) and _
       (_Sounds(i).lpBuf  <>NULL ) and _ 
       (_Sounds(i).nLoops  >0    ) and _
       (_Sounds(i).Paused  =false) then

      if (_Sounds(i).Muted=false) then 
        MixerChannels(nChannels)=_Sounds(i).lpBuf:nChannels+=1
        if _Sounds(i).Speed=1.0 then 
           _copyright(_Sounds(i).lpBuf  , _
                      _Sounds(i).lpUserStart, _
                     @_Sounds(i).lpPlay , _
                      _Sounds(i).lpUserEnd  , _
                     @_Sounds(i).nLoops , _
                      Plug->Buffersize  )

        elseif _Sounds(i).Speed>0.0 then  
          _copysliceright(_Sounds(i).lpBuf  , _
                          _Sounds(i).lpUserStart, _
                         @_Sounds(i).lpPlay , _
                          _Sounds(i).lpUserEnd  , _
                         @_Sounds(i).nLoops , _
                          _Sounds(i).Speed  , _
                          Plug->Buffersize  )
        else
          _copysliceleft(_Sounds(i).lpBuf  , _
                         _Sounds(i).lpUserStart, _
                        @_Sounds(i).lpPlay , _
                         _Sounds(i).lpUserEnd  , _
                        @_Sounds(i).nLoops , _
                         _Sounds(i).Speed  , _
                         Plug->Buffersize  )
        end if
        if _Sounds(i).Volume<>1.0 then
          _scale(_Sounds(i).lpBuf,_Sounds(i).lpBuf,_Sounds(i).Volume,Plug->Buffersize)
        end if
        ' paning needs stereo
        if _Plugs(_Plug).Fmt.nChannels=2 then
          if _Sounds(i).pan<>0.0 then
             _pan(_Sounds(i).lpBuf  , _
                  _Sounds(i).lpBuf  , _
                  _Sounds(i).lVolume, _
                  _Sounds(i).rVolume, _
                  Plug->Buffersize  )
          end if
        end if
        if (_Sounds(i).Callback<>NULL) and (_Sounds(i).EnabledCallback=true) then
          _Sounds(i).Callback(cptr(short ptr,_Sounds(i).lpBuf), _
                              Plug->FMT.nChannels        , _
                              Plug->Buffersize shr Plug->FMT.nChannels)
        end if

      else ' only move playpointer
        if (_Sounds(i).Speed=1.0) then
          _moveright(_Sounds(i).lpUserStart, _
                    @_Sounds(i).lpPlay , _
                     _Sounds(i).lpUserEnd  , _
                    @_Sounds(i).nLoops , _
                     Plug->Buffersize)

        elseif (_Sounds(i).Speed>0.0) then
          _movesliceright(_Sounds(i).lpUserStart, _
                         @_Sounds(i).lpPlay , _
                          _Sounds(i).lpUserEnd  , _
                         @_Sounds(i).nLoops , _
                          _Sounds(i).Speed  , _
                          Plug->Buffersize)
        else
          _movesliceleft(_Sounds(i).lpUserStart, _
                        @_Sounds(i).lpPlay , _
                         _Sounds(i).lpUserEnd  , _
                        @_Sounds(i).nLoops , _
                         _Sounds(i).Speed  , _
                         Plug->Buffersize)
        end if    
      end if ' is muted
    end if ' is sound active
    ' soundplayback are ready
    if (_Sounds(i).lpStart<>NULL) and (_Sounds(i).nLoops<1) then
      ' user has not the hSound handle mark it as free
      if _Sounds(i).UserControl=false then _Sounds(i).lpStart=NULL
    end if
    if nChannels=_MaxChannels then exit for
  next
end if

  if nChannels<1 then
    ' there can be played sounds but muted !
    zero(Plug->lpCurentBuffer,Plug->Buffersize)
  elseif nChannels=1 then
    ' one channel nothing to mix!
    copy(Plug->lpCurentBuffer,MixerChannels(0),Plug->Buffersize)
  else
    ' now time to mix MixerChannels[] to Plug->lpCurentBuffer
    _mixer Plug->lpCurentBuffer,@MixerChannels(0),nChannels,Plug->Buffersize
  end if
  if _MasterVolume<>1.0 then
    _scale(Plug->lpCurentBuffer,Plug->lpCurentBuffer,_MasterVolume,Plug->Buffersize)
  end if

  for i=0 to MAX_FILTERS-1
    if (_MasterFilters(i).Enabled=true) and (_MasterFilters(i).dB<>0.0f) then
      _Filter(Plug->lpCurentBuffer, _
              Plug->lpCurentBuffer, _
              @_MasterFilters(i)  , _
              Plug->Buffersize    )
    end if
  next

  if (_MasterCallback<>NULL) and (_EnabledCallback=true) then
    _MasterCallback(cptr(short ptr,Plug->lpCurentBuffer), _
                    Plug->FMT.nChannels, _
                    Plug->Buffersize shr Plug->FMT.nChannels)

  end if
end sub

' fill wave header struct 
' return in lpDataPos the file pos of the first sample.
private _
function GetWaveInfo(_B FileName  as string , _
                     _R Hdr       As _PCM_FILE_HDR , _
                     _B lpDataPos as integer ptr) as fbsboolean

  Dim as integer FileSize, fSize, hFile, L
  if lpDataPos=NULL then return false
  hFile = FreeFile()
  if open(FileName for binary access read As #hFile)=0 then
    FileSize = lof(hFile)
    if FileSize > _PCM_FILE_HDR_SIZE then
      get #hFile,, Hdr.ChunkRIFF
      if Hdr.ChunkRIFF = _RIFF then
        get #hFile,, Hdr.ChunkRIFFSize
        get #hFile,, Hdr.ChunkID
        if Hdr.ChunkID = _WAVE then
          fSize = seek(hFile)
          Hdr.Chunkfmt=0
          while (Hdr.Chunkfmt <> _fmt) and (eof(hFile) = 0)
            get #hFile, fSize, Hdr.Chunkfmt
            fSize = fSize + 1
          wend
          if Hdr.Chunkfmt = _fmt then
            get #hFile, , Hdr.ChunkfmtSize
            if Hdr.ChunkfmtSize >= _PCM_FMT_SIZE then
              get #hFile, , Hdr.wFormattag
              if Hdr.wFormattag = _WAVE_FORMAT_PCM then
                get #hFile, , Hdr.nChannels
                get #hFile, , Hdr.nRate
                get #hFile, , Hdr.nBytesPerSec
                get #hFile, , Hdr.Framesize
                get #hFile, , Hdr.nBits
                Hdr.Chunkdata=0
                fSize = seek(hFile)
                while (Hdr.Chunkdata <> _data) and (eof(hFile) = 0)
                  get #hFile, fSize, Hdr.Chunkdata
                  fSize = fSize + 1
                wend
                if Hdr.Chunkdata = _data Then
                  get #hFile, , Hdr.ChunkdataSize
                  if Hdr.ChunkdataSize > 0 and eof(hFile) = 0 Then
                    L = seek(hFile)
                    *lpDataPos = L
                    close #hFile
                     return true
                  end if ' Chunkdatasize>0
                end if ' Chunkdata=_data
              end if ' wFormattag = WAVE_FORMAT_PCM
            end if ' ChunkfmtSize >= PCM_FMT_SIZE
          end if ' Chunkfmt = _fmt
        end if ' ChunkID = _WAVE
      end if ' ChunkRIFF = _RIFF
    end if ' FileSize > PCM_FILE_HDR_SIZE
  end if ' open=0
  close #hFile
  return false
end function

private _
function _LoadWave(_B Filename        as string, _
                   _B nRateTarget     as integer , _
                   _B nBitsTarget     as integer , _
                   _B nChannelsTarget as integer , _
                   _B lpnBytes        as integer ptr) as any ptr

  dim as _PCM_FILE_HDR hdr
  dim as integer   hFile,SeekPos,nBytesTarget,nSamples,nSamplesTarget,i,oPos,cPos
  dim as single    l,r
  dim as double    Scale,nPos
  dim as ubyte     v8
  dim as short     v16
  dim as short ptr p16

  oPos=-1
  if GetWaveInfo(Filename,hdr,@SeekPos)=true then
    nSamples=hdr.Chunkdatasize \ hdr.Framesize
    Scale=hdr.nRate/nRateTarget
    nSamplesTarget=nSamples*(1.0/Scale)
    nBytesTarget=nSamplesTarget*(nBitsTarget\8)*nChannelsTarget
    hFile=Freefile()
    if open(FileName for binary access read as #hFile)=0 then
      seek #hFile,SeekPos
      p16=callocate(nBytesTarget)
      if p16=NULL then
        close #hFile
        return NULL 
      end if

      if nSamples<=nSamplesTarget then
        for i=0 to nSamplesTarget-1
          ' jump over in source
          if oPos<>cPos then
            ' read samples l,r -0.5 - 0.5
            if hdr.nBits=8 then
              'read ubyte 0<->255
              get #hFile,,v8
              ' convert to -128.0 <-> +127.0
              l=csng(v8):l-=128
              ' convert to -0.5 <-> +0.5
              l*=(0.5f/128.0f)
              if hdr.nChannels=2 then 
                get #hFile,,v8
                r=csng(v8):r-=128
                ' convert to -0.5 <-> +0.5
                r*=(0.5f/128.0f)  
              else
                r=l
              end if
            else
              get #hFile,,v16:l=(0.5f/32767.0f)*v16
              if hdr.nChannels=2 then 
                get #hFile,,v16:r=(0.5f/32767.0f)*v16
              else 
                r=l
              end if
            end if
            oPos=cPos
          end if
          ' write every in target
          if nChannelsTarget=1 then
            p16[i    ]=cshort(l*16383f + r*16383f)
          else
            p16[i*2  ]=cshort(l*32767.0f)
            p16[i*2+1]=cshort(r*32767.0f)
          end if
          nPos+=scale:cPos=int(nPos)
          ' don't read more than len(source)
          if cPos>=nSamples then exit for
        next
      else ' read every source Sample
        scale=(1.0/scale)
        for i=0 to nSamples-1
          ' read samples l,r -0.5 - +0.5
          if hdr.nBits=8 then
            'read ubyte 0<->255
            get #hFile,,v8
            ' convert to -128.0 <-> +127.0
            l=csng(v8):l-=128
            ' convert to -0.5 <-> +0.5
            l*=(0.5f/128.0f)
            if hdr.nChannels=2 then 
              get #hFile,,v8
              r=csng(v8):r-=128
              ' convert to -0.5 <-> +0.5
              r*=(0.5f/128.0f)  
            else
              r=l
            end if
          else
            get #hFile,,v16:l=(0.5f/32767.0f)*v16
            if hdr.nChannels=2 then
              get #hFile,,v16:r=(0.5f/32767.0f)*v16
            else 
              r=l
            end if
          end if
          ' jump over in destination
          if oPos<>cPos then 
            if nChannelsTarget=1 then
              p16[cPos    ]=cshort(l*16383.5f + r*16383.5f)
            else
              p16[cPos*2  ]=cshort(l*32767.0f)
              p16[cPos*2+1]=cshort(r*32767.0f)
            end if
            oPos=cPos
          end if
          nPos+=scale:cPos=int(nPos)
          ' don't write more than len(target)
          if cPos>=(nSamplesTarget-1) then exit for
        next
      end if
      close #hFile
      *lpnBytes=nBytesTarget
      return p16
    end if ' open=0
  end if ' GetWaveInfo<>0
  return NULL
end function

private _
function _Adjust_Path(_B Path as string) as string
#ifdef __FB_WIN32__
  if right(Path,1)<>"\" then Path=Path + "\"
#else
  if right(Path,1)<>"/" then Path=Path + "/"
#endif
  return Path
end function

private _
function _Get_PlugPath() as string
  dim as string tmp
  tmp=_Adjust_Path(exepath())
  return tmp
end function

private _
function _initplugout(_B filename as string, _
                      _R p        as FBS_Plug) as fbsboolean
  dprint("fbs:_initplugout")
  p.plug_hLib=0
  p.plug_hLib=dylibload(filename)
  if p.plug_hLib<>0 then
    p.plug_isany=dylibsymbol(p.plug_hLib, "PLUG_ISANY" )
    if (p.plug_isany<>NULL) then
      if p.plug_isany(p)=true then
        p.plug_init =dylibsymbol( p.plug_hLib, "PLUG_INIT"  )
        p.plug_start=dylibsymbol( p.plug_hLib, "PLUG_START" )
        p.plug_stop =dylibsymbol( p.plug_hLib, "PLUG_STOP"  )
        p.plug_exit =dylibsymbol( p.plug_hLib, "PLUG_EXIT"  )
        p.plug_error=dylibsymbol( p.plug_hLib, "PLUG_ERROR" )
        if (p.plug_init <>NULL) and _
           (p.plug_start<>NULL) and _
           (p.plug_stop <>NULL) and _
           (p.plug_exit <>NULL) and _
           (p.plug_error<>NULL) then
            return true
        else
          dprint("corupt plugout interface!")
          #ifdef __FB_WIN32__
          dylibfree p.plug_hLib
          p.plug_hLib=NULL
          #endif
          return false
        end if
      else
        dprint(filename + " not aviable!")
        #ifdef __FB_WIN32__
        dylibfree p.plug_hLib
        p.plug_hLib=NULL
        #endif
        return false
      end if
    else
      dprint("missing interface member (plug_isany)")
      #ifdef __FB_WIN32__
      dylibfree p.plug_hLib
      p.plug_hLib=NULL
      #endif
      return false
    end if
  else
    dprint("can't load plugout:" + filename + "!")
    return false
  end if
end function

pluglist:
#ifdef __FB_WIN32__
  data 1
  data "plug-mm.dll"
#else
  data 3
  data "libplug-alsa.so"
  data "libplug-dsp.so"
  data "libplug-arts.so"
#endif

private _
sub _Enumerate_Plugs()
  dprint("Enumerate Plugs:")
  dim as integer nPlugs
  dim as string  n,plugname
  dim as FBS_Plug _new
  if _nPlugs>0 then exit sub
  n=_PlugPath

  restore pluglist
  read nPlugs
  while nPlugs>0
    read plugname
    plugname=n+plugname
    if _initplugout(plugname,_new)=true then
      redim preserve _Plugs(_nPlugs)
      _Plugs(_nPlugs)=_new
      _nPlugs+=1
    end if
    nPlugs-=1
  wend
end sub

sub _init() constructor
  dprint("fbs:constructor()")
  _Seed        = 13
  _PlugPath    =_Get_PlugPath()
  _Plug        =-1
  _MasterVolume=1.0
  _MaxChannels =128
end sub

sub _exit() destructor
  dprint("fbs:destructor~")
  if (_IsRunning=true) then fbs_Stop
  if (_IsInit   =true) then fbs_Exit
end sub

function FBS_Get_NumOfPlugouts() as integer export
  return _nPlugs
end function

function FBS_Get_PlugError() as string export
  if _Plug>-1 then return _Plugs(_Plug).plug_error()
end function

function FBS_Get_PlugName() as string export
  if _Plug>-1 then return _Plugs(_Plug).PlugName
end function

public _
function FBS_Get_PlugDevice() as string export
  if _Plug>-1 then return _Plugs(_Plug).DeviceName
end function

public _
function FBS_Get_PlugBuffersize() as integer export
  if _Plug>-1 then return _Plugs(_Plug).Buffersize
end function

public _
function FBS_Get_PlugBuffers() as integer export
  if _Plug>-1 then return _Plugs(_Plug).nBuffers
end function

public _
function FBS_Get_PlugFramesize() as integer export
  if _Plug>-1 then return _Plugs(_Plug).Framesize
end function

public _
function FBS_Get_PlugFrames() as integer export
  if _Plug>-1 then return _Plugs(_Plug).nFrames
end function

public _
function FBS_Get_PlugRate() as integer export
  if _Plug>-1 then return _Plugs(_Plug).Fmt.nRate
end function

public _
function FBS_Get_PlugBits() as integer export
  if _Plug>-1 then return _Plugs(_Plug).Fmt.nBits
end function

public _
function FBS_Get_PlugChannels() as integer export
  if _Plug>-1 then return _Plugs(_Plug).Fmt.nChannels
end function

public _
function FBS_Get_PlugSigned() as fbsboolean export
  if _Plug>-1 then return _Plugs(_Plug).Fmt.Signed
end function

public _
function FBS_Get_PlugRunning() as fbsboolean export
  return _IsRunning
end function

public _
function FBS_Get_PlayingSounds() as integer export
  if (_IsRunning=true) then return _nPlayingSounds
end function

public _
function FBS_Get_PlayingStreams() as integer export
  if (_IsRunning=true) then return _nPlayingStreams
end function

public _
function FBS_Get_PlayedBytes() as integer export
  if (_IsInit=true) then return _nPlayedBytes
end function

public _
function FBS_Get_PlayedSamples() as integer export
  if FBS_Get_PlayedBytes>0 then return int(FBS_Get_PlayedBytes()\_Plugs(_Plug).Framesize)
end function

public _
function FBS_Get_PlayTime() as double export
  if FBS_Get_PlayedSamples>0 then return cdbl(FBS_Get_PlayedSamples()/_Plugs(_Plug).fmt.nRate)
end function

public _
function FBS_Init(_B nRate      as integer=44100, _
                  _B nChannels  as integer=    2, _
                  _B nBuffers   as integer=    3, _
                  _B nFrames    as integer= 2048, _
                  _B index      as integer=   -1) as fbsboolean export

  dim as integer     i
  dim as fbsboolean  ret
  dim as FBS_Plug    _new
  dprint("fbs:init()")

  if (_nPlugs<1) then
    dprint("fbs:init() _Enumerate_Plugs()")
    _Enumerate_Plugs()
  end if

  if _nPlugs=0 then
    dprint("fbs:init _nPlugs=0")
    _IsInit=false
    return false
  end if
  if _Plug>-1 then
    dprint("fbs:init _Plug>-1")
    _Plugs(_Plug).plug_stop()
    _Plugs(_Plug).plug_exit()
    _Plug=-1
  end if
  dprint("fbs:init for i=0 to _nPlugs-1")
  for i=0 to _nPlugs-1
    dprint("  fbs:init _Plugs(" & i & ").Fmt.nRate =nRate")
    _Plugs(i).Fmt.nRate    =nRate
    _Plugs(i).Fmt.nBits    =16 ' !!! changed no 8 bit support any more !!!
    _Plugs(i).Fmt.nChannels=nChannels
    _Plugs(i).nBuffers     =nBuffers
    _Plugs(i).nFrames      =nFrames
    _Plugs(i).Fillbuffer   =@_FillBuffer
    dprint("  fbs:init _Plugs(" & i & ").Index=" & str(index))
    _Plugs(i).Index=index
    if _Plugs(i).plug_init<>NULL then
      dprint("  fbs:init if _Plugs(i).plug_init(_Plugs(i))=true then")
      if _Plugs(i).plug_init(_Plugs(i))=true then 
        dprint("fbs:init _Plug=i:exit for")
        _Plug=i:exit for
      end if
    else
      dprint("fbs:init _Plugs(" & i & ").plug_init=NULL !!!")
      beep
    end if
    dprint("  fbs:init next")
  next
  dprint("fbs:init _Plug=" & str(_Plug))

  if _Plug<>-1 then
   dprint("fbs:init set all proc's !!!")
   _mix   = @mix16  
   _scale = @scale16
    if _Plugs(_Plug).Fmt.nChannels=1 then
      _copyright          =@copyright16
      _moveright          =@moveright16
      _copysliceright     =@copysliceright16
      _movesliceright     =@movesliceright16
      _copysliceleft      =@copysliceleft16
      _movesliceleft      =@movesliceleft16
      _pan                = NULL '!!!
      _CopySliceMP3Frame  =@copyslicemp3frame16
      _ScaleMP3FrameStereo=@scalemp3frame_21_16
      _ScaleMP3FrameMono  =@scalemp3frame_11_16
      _PitchShift         =@_PitchShiftMono_asm
      _Filter             =@_Filter_Mono_asm16
    else
      _copyright          =@copyright32
      _moveright          =@moveright32
      _copysliceright     =@copysliceright32
      _movesliceright     =@movesliceright32
      _copysliceleft      =@copysliceleft32
      _movesliceleft      =@movesliceleft32
      _pan                =@pan16
      _CopySliceMP3Frame  =@copyslicemp3frame32
      _ScaleMP3FrameStereo=@scalemp3frame_22_16
      _ScaleMP3FrameMono  =@scalemp3frame_12_16
      _PitchShift         =@_PitchShiftStereo_asm
      _Filter             =@_Filter_Stereo_asm16
    end if

    _IsInit=true
    dprint("fbs:init fbs_start()")
    return fbs_start()
  else
    _IsInit=false
    return false
  end if
end function

public _
function FBS_Start() as fbsboolean export
  if _Plug=-1      then return false  
  dprint("fbs:start")
  _IsRunning=_Plugs(_Plug).plug_start()
  return _IsRunning
end function

public _
function FBS_Stop() as fbsboolean export
  dim as fbsboolean ret
  if _Plug=-1 then return true
  if _IsRunning=false then return true
  dprint("fbs:stop")
  ret=_Plugs(_Plug).plug_stop()
  ' !!! sleep 500
  if ret=true then _IsRunning=false
  return ret
end function

public _
function FBS_Exit() as fbsboolean export
  dprint("fbs:exit()")
  dim as integer i

  if _Plug=-1 then return true
  if _IsRunning=true then 
    FBS_Stop()
    _IsRunning=false
    ' !!! sleep 300
  end if

  if (_MP3Stream.InUse=true) then fbs_end_MP3Stream

  ' free all resources from streams 
  with _MP3Stream
    if (.lpInArray<>NULL) then
      deallocate .lpInArray:.lpInArray=NULL  
    end if
    if (.lpStreamSamples<>NULL) then
      deallocate .lpStreamSamples:.lpStreamSamples=NULL  
    end if
    if (.lpBuf<>NULL) then
      deallocate .lpBuf:.lpBuf=NULL  
    end if
    if (.lpStart<>NULL) then  
      deallocate .lpStart:.lpStart=NULL  
    end if
  end with

  if _nSounds>0 then
    for i=0 to _nSounds-1
      ' signal stop
      if _Sounds(i).nLoops<>0 then
        _Sounds(i).paused=true
      end if
      _Sounds(i).nLoops =0  
      if (_Sounds(i).lpBuf<>NULL) then
        if (_Sounds(i).lpBuf=_Sounds(i).lpOrg) then
          deallocate _Sounds(i).lpBuf
          _Sounds(i).lpBuf=NULL
          _Sounds(i).lpOrg=NULL
        else
          dprint("!!! pointer value are corrupt !!!")
        end if
      end if
      _Sounds(i).lpStart=NULL
      _Sounds(i).lpPlay =NULL
      _Sounds(i).lpEnd  =NULL
    next
  end if
  if (_nWaves>0) then
    for i=0 to _nWaves-1
      if _Waves(i).lpStart<>NULL then
        deallocate _Waves(i).lpStart
        _Waves(i).lpStart=NULL
        _Waves(i).nBytes=0
      end if
    next
    _nWaves=0
  end if
  _Plugs(_Plug).plug_exit()
  sleep 500
#ifdef __FB_WIN32__
  if _Plugs(_Plug).plug_hLib<>NULL then
      dylibfree _Plugs(_Plug).plug_hLib
     _Plugs(_Plug).plug_hLib=NULL
  end if
#endif
  _nPlugs=0
  _Plug=-1
  _IsInit=false
  dprint("fbs:exit~")
   return true
end function

public _
function FBS_Create_Wave(_B nSamples as integer    , _
                         _B hWave    as integer ptr, _
                         _B lpWave   as any ptr ptr) as fbsboolean export
  dim as any ptr _new
  dim as integer nBytes,flag,i
  if (hWave   =NULL) then return false
  if (lpWave  =NULL) then return false
  if (_Plug   =  -1) then *hWave=-1:lpWave=NULL:return false
  if (nSamples<   1) then *hWave=-1:lpWave=NULL:return false

  nBytes=nSamples*(_Plugs(_Plug).fmt.nBits\8)*_Plugs(_Plug).fmt.nChannels
  _new=callocate(nBytes)
  if _new=NULL     then *hWave=-1:return false
  ' _new sound
  if _nWaves=0 then
    redim _Waves(_nWaves)
    _Waves(_nWaves).lpStart= _new
    _Waves(_nWaves).nBytes=nBytes
    *lpWave= _new
    *hWave=_nWaves
    _nWaves+=1
  else
    flag=-1
    for i=0 to _nWaves-1
      if _Waves(i).lpStart=NULL then flag=i:exit for
    next

    if flag>-1 then
      _Waves(flag).lpStart= _new
      _Waves(flag).nBytes=nBytes
      *lpWave= _new
      *hWave=flag
    else
      redim preserve _Waves(_nWaves)
      _Waves(_nWaves).lpStart= _new
      _Waves(_nWaves).nBytes=nBytes
      *lpWave= _new
      *hWave=_nWaves
      _nWaves+=1
    end if
  end if
   return true
end function

public _
function FBS_Load_WAVFile(_B Filename as string, _
                          _B hWave    as integer ptr) as fbsboolean export
  dim as any ptr _new
  dim as integer nBytes,flag,i
  if hWave  =NULL  then return false  
  if _IsInit=false then *hWave=-1:return false

  _new=_LoadWave(FileName, _
                _Plugs(_Plug).Fmt.nRate    , _
                _Plugs(_Plug).Fmt.nBits    , _
                _Plugs(_Plug).Fmt.nChannels, _
                @nBytes)

  if _new=NULL then 
    *hWave=-1
    return false
  end if
  ' new sound
  if _nWaves=0 then
    redim _Waves(_nWaves)
    _Waves(_nWaves).lpStart= _new
    _Waves(_nWaves).nBytes=nBytes
    *hWave=_nWaves
    _nWaves+=1
  else
    flag=-1
    for i=0 to _nWaves-1
      if _Waves(i).lpStart=NULL then flag=i:exit for
    next

    if flag>-1 then
      _Waves(flag).lpStart= _new
      _Waves(flag).nBytes=nBytes
      *hWave=flag
    else
      redim preserve _Waves(_nWaves)
      _Waves(_nWaves).lpStart= _new
      _Waves(_nWaves).nBytes=nBytes
      *hWave=_nWaves
      _nWaves+=1
    end if
  end if
   return true
end function


'  ##############
' # mp3 libmad #
'##############
const as integer FRAMESIZE = 1152
const MP3_SCALE  as single = 1.0f/8325.0f

type MP3_STEREO_SAMPLE
  as short l
  as short r
end type
type MP3_BUFFER
  as ubyte PTR Start
  as integer   Size
  as integer   hOut
  as _PCM_FILE_HDR wavehdr
  as ubyte PTR lpfilebuf
end type

' input mp3 stream
private _
function ConvertMP3Stream() as integer
  if _MP3Stream.InUse=false then return 0

  if _MP3Stream.mSynth.pcm.length<1 then
    dprint("convert mp3 stream no samples!")
    return 0
  end if
  _MP3Stream.nSamplesTarget=_MP3Stream.mSynth.pcm.length 

  if (_MP3Stream.mSynth.pcm.channels>1) then
    _ScaleMP3FrameStereo(_MP3Stream.lpStreamSamples, _
                        @_MP3Stream.mSynth.pcm.samples(0,0), _
                        @_MP3Stream.mSynth.pcm.samples(1,0), _
                         _MP3Stream.nSamplesTarget)
    '_Streams(hStream).nSamplesTarget shl=1  
  else
    _ScaleMP3FrameMono(_MP3Stream.lpStreamSamples, _
                      @_MP3Stream.mSynth.pcm.samples(0,0), _
                       _MP3Stream.nSamplesTarget)
  end if

  _MP3Stream.nBytesTarget=_MP3Stream.nSamplesTarget * _
                                (_Plugs(_Plug).fmt.nBits\8) * _
                                 _Plugs(_Plug).fmt.nChannels 

  if _MP3Stream.p16=NULL then _MP3Stream.p16=cptr(short PTR,_MP3Stream.lpStart)

  if (_MP3Stream.mSynth.pcm.Samplerate=_Plugs(_Plug).fmt.nRate) then
    while ((_MP3Stream.nOuts+_MP3Stream.nBytesTarget)>_MP3Stream.nOutSize) and _
           (_MP3Stream.IsStreaming=true)
      sleep 1
    wend 
    if _MP3Stream.IsStreaming=false then return 0
    CopyMP3Frame _MP3Stream.lpStart , _
                @_MP3Stream.p16     , _
                 _MP3Stream.lpEnd   , _
                 _MP3Stream.lpStreamSamples, _
                 _MP3Stream.nBytesTarget
    return _MP3Stream.nBytesTarget
  else
    _MP3Stream.scale =_MP3Stream.mSynth.pcm.Samplerate/_Plugs(_Plug).fmt.nRate
    _MP3Stream.nBytesTarget*=(1.0/_MP3Stream.scale)
    while ((_MP3Stream.nOuts+_MP3Stream.nBytesTarget)>_MP3Stream.nOutSize) and _
           (_MP3Stream.IsStreaming=true)
      sleep 1
    wend
    if _MP3Stream.IsStreaming=false then return 0
    _CopySliceMP3Frame(_MP3Stream.lpStart , _
                      @_MP3Stream.p16     , _
                       _MP3Stream.lpEnd   , _
                       _MP3Stream.lpStreamSamples, _
                       _MP3Stream.scale ,_
                       _MP3Stream.nBytesTarget)
    return _MP3Stream.nBytesTarget
  end if
end function


private _
function inputcallback cdecl (_B lpData   as any ptr, _
                         _B lpStream as mad_stream PTR) as integer
  dim as MP3_BUFFER PTR buf=cptr(MP3_BUFFER PTR,lpData)
  if buf->Size=0 then return MAD_FLOW_STOP
  mad_stream_buffer  (lpStream, buf->Start,buf->Size)
  buf->Size=0
  return MAD_FLOW_CONTINUE
end function

private _
function outputcallback cdecl (_B lpData   as any ptr             , _
                          _B lpHeader as mad_header PTR, _
                          _B lpPCM    as mad_pcm    PTR) as integer
  dim as MP3_BUFFER PTR buf=cptr(MP3_BUFFER PTR,lpData)
  dim as integer i
  if lpPCM->channels>1 then
      _ScaleMP3FrameStereo(buf->lpFileBuf, _
                           @lpPCM->samples(0,0), _
                           @lpPCM->samples(1,0), _, _
                           lpPCM->length)
  else
    _ScaleMP3FrameMono(buf->lpFileBuf, _
                      @lpPCM->samples(0,0), _
                       lpPCM->length)
  end if

  ' first time write wave header
  if buf->wavehdr.ChunkDataSize=0 then
    buf->wavehdr.ChunkRIFF     = _RIFF
    buf->wavehdr.ChunkRIFFSize = sizeof(_PCM_FILE_HDR)-8
    buf->wavehdr.ChunkID       = _WAVE
    buf->wavehdr.Chunkfmt      = _fmt
    buf->wavehdr.ChunkfmtSize  = 16 
    buf->wavehdr.wFormatTag    = 1
    buf->wavehdr.nChannels     = _Plugs(_Plug).fmt.nChannels
    buf->wavehdr.nRate         = lpPCM->samplerate
    buf->wavehdr.nBytesPerSec  = (_Plugs(_Plug).fmt.nBits\8)*lpPCM->samplerate*_Plugs(_Plug).fmt.nChannels
    buf->wavehdr.Framesize     = (_Plugs(_Plug).fmt.nBits\8)*_Plugs(_Plug).fmt.nChannels
    buf->wavehdr.nBits         =_Plugs(_Plug).fmt.nBits
    buf->wavehdr.Chunkdata     = _data
    put #buf->hOut,,buf->wavehdr
  end if

  buf->wavehdr.ChunkRIFFSize+=lpPCM->length*buf->wavehdr.Framesize
  buf->wavehdr.ChunkdataSize+=lpPCM->length*buf->wavehdr.Framesize
  put #buf->hOut,,buf->lpFileBuf[0],lpPCM->length*buf->wavehdr.Framesize
  return MAD_FLOW_CONTINUE
end function

private _
function errorcallback cdecl (_B lpData   as any ptr             , _
                         _B lpStream as mad_stream PTR, _
                         _B lpFrame  as mad_frame  PTR) as integer

  dim as MP3_BUFFER PTR buf = cptr(MP3_BUFFER PTR,lpData)

  if ( MAD_RECOVERABLE(lpStream->error) ) then
    return  MAD_FLOW_CONTINUE		
  else ' not recoverable
    if (lpStream->error=MAD_ERROR_BUFLEN) then 
      return  MAD_FLOW_CONTINUE
    else
      dprint("mp3 error callback not recoverable !")
      return MAD_FLOW_BREAK
    end if
  end if
end function

private _
function _DecodeMP3(_B lpStart   as any ptr, _
                _B Size      as integer, _
                _B hOut      as integer) as integer

  dim as MP3_BUFFER  buf
  dim as mad_decoder decoder
  dim as integer     result

  ' initialize our private message structure
  buf.Start    = lpStart
  buf.Size     = Size
  buf.hOut     = hOut
  buf.lpFileBuf=allocate(sizeof(short)*1152*2*4)

  ' configure input, output, and error _FUs
  mad_decoder_init(@decoder        , _
                   @buf            , _
                   @inputcallback  , _
                   0               , _ ' header
                   0               , _ ' filter
                   @outputcallback , _
                   @errorcallback  , _ 
                   0)                  ' message

  ' start decoding 
  result = mad_decoder_run(@decoder, MAD_DECODER_MODE_SYNC)
  seek buf.hOut,1
  put #buf.hOut,,buf.wavehdr
  ' release the decoder
  mad_decoder_finish(@decoder)
  if buf.lpFileBuf<>NULL then deallocate buf.lpFileBuf
  return result
end function

public _
function FBS_Load_MP3File(byval Filename as string , _
                     byval lphWave  as integer ptr , _
                     byval tmpfile  as string ="") as fbsboolean export
  static as integer tmpid=0
  dim as byte ptr lpMP3
  dim as integer hFile,hOut,size,ret
  dim as string  infile,outtmp

  if lphWave=NULL then return false  
  *lphWave=-1
  if _IsInit=false then return false  

  infile=FileName

  hFile=Freefile
  if open(infile for binary access read as #hFile)<>0 then return false  
  size=lof(hFile)
  if size=0     then close #hfile:return false
  lpMP3=callocate(size)
  if lpMP3=NULL then close #hfile:return false

  get #hFile,,*lpMP3,size

  tmpid+=1
  if tmpfile="" then 
    outtmp="tmpfilemp3" & trim(str(tmpid)) & ".wav"
    if len(dir(outtmp)) then kill outtmp
  else
    outtmp=tmpfile
  end if

  hOut=Freefile()
  if open(outtmp for binary access write as #hOut)<>0 then
    close #hfile
    if (lpMP3<>NULL) then  deallocate lpMP3:lpMP3=NULL 
    return false
  end if

  ret=_DecodeMP3(lpMP3,size,hOut)
  close #hOut
  close #hFile
  if (lpMP3<>NULL) then deallocate lpMP3:lpMP3=NULL

  if ret=0 then
    if FBS_Load_WAVFile(outtmp,lphWave)=true then
      kill outtmp
       return true
    else
      kill outtmp
      *lphWave=-1
      return false
    end if
  else
    kill outtmp
    *lphWave=-1
    return false
  end if
end function

#define IN_SIZE 8192
private _
sub _StreamMP3(byval dummy as any ptr)
  if _MP3Stream.InUse=false then exit sub
  _MP3Stream.IsStreaming=true

  ' loop over the whole stream
  while (_MP3Stream.IsStreaming=true)
    ' get first buffer or fill curent buffer     
    if (_MP3Stream.mStream.buffer=NULL) or  _
       (_MP3Stream.mStream.error=MAD_ERROR_BUFLEN) then

      if (_MP3Stream.mStream.next_frame<>NULL) then
        _MP3Stream.nReadRest =_MP3Stream.mStream.bufend-_MP3Stream.mStream.next_frame
        if _MP3Stream.nReadRest>0 then
          copy(_MP3Stream.lpInArray,_MP3Stream.mStream.next_frame,_MP3Stream.nReadRest)
          _MP3Stream.lpRead =_MP3Stream.lpInArray+_MP3Stream.nReadRest
          _MP3Stream.nReadSize =IN_SIZE-_MP3Stream.nReadRest
        end if
      else
        _MP3Stream.nReadSize=IN_SIZE
        _MP3Stream.lpRead=_MP3Stream.lpInArray
        _MP3Stream.nReadRest=0
      end if
      ' enought bytes in stream?
      if (_MP3Stream.nInSize<_MP3Stream.nReadSize) then 
        _MP3Stream.nReadSize=_MP3Stream.nInSize
      end if  
      ' read from stream^or exit the decoding loop
      if (_MP3Stream.nReadSize=0) and  (_MP3Stream.nInSize=0) then exit while
      get #_MP3Stream.hFile,,*_MP3Stream.lpRead,_MP3Stream.nReadSize
      _MP3Stream.nInSize-=_MP3Stream.nReadSize

      ' last frame fill the rest with 0
      if (_MP3Stream.nInSize=0) then
        _MP3Stream.GuardPTR =_MP3Stream.lpRead+_MP3Stream.nReadSize
        zero _MP3Stream.GuardPTR,MAD_BUFFER_GUARD
        _MP3Stream.nReadSize+=MAD_BUFFER_GUARD
      end if

      mad_stream_buffer(@_MP3Stream.mStream, _
                         _MP3Stream.lpINArray, _
                         _MP3Stream.nReadSize+_MP3Stream.nReadRest)
      _MP3Stream.mStream.error=0
    end if '(mStream.buffer=NULL) or (mStream.error=MAD_ERROR_BUFLEN)

    if ( mad_frame_decode(@_MP3Stream.mFrame,@_MP3Stream.mStream)<>0) then
      if ( MAD_RECOVERABLE(_MP3Stream.mStream.error) ) then
        if ( (_MP3Stream.mStream.error<>MAD_ERROR_LOSTSYNC) or _
             (_MP3Stream.mStream.this_frame<>_MP3Stream.GuardPTR) or _
            ( _
            ( (_MP3Stream.mStream.this_frame[0]<>asc("I")) and _
              (_MP3Stream.mStream.this_frame[1]<>asc("D")) and _
              (_MP3Stream.mStream.this_frame[2]<>asc("3")) ) _
            or _
            ( (_MP3Stream.mStream.this_frame[0]<>asc("T")) and _
              (_MP3Stream.mStream.this_frame[1]<>asc("A")) and _
              (_MP3Stream.mStream.this_frame[2]<>asc("G")) ) _
            )  _
           ) then 
          goto get_next_frame
        end if  
      else ' not recoverable
        if (_MP3Stream.mStream.error=MAD_ERROR_BUFLEN) then 
          goto get_next_frame ' get next bytes from stream
        else
          _MP3Stream.RetStatus=4
          exit while
        end if
      end if
    else ' no decode error
      _MP3Stream.nFrames+=1
      mad_synth_frame(@_MP3Stream.mSynth,@_MP3Stream.mFrame)
      _MP3Stream.nOuts+=ConvertMP3Stream()
    end if
  get_next_frame:
  wend

  if (_MP3Stream.nOuts>0) then
    _MP3Stream.nReadRest=_MP3Stream.nOuts mod _Plugs(_Plug).Buffersize
    if _MP3Stream.nReadRest>0 then 
      _MP3Stream.nReadRest=_Plugs(_Plug).Buffersize-_MP3Stream.nReadRest
      while ((_MP3Stream.nOuts+_MP3Stream.nReadRest)>_MP3Stream.nOutSize)
        sleep 1
      wend 
      zerobuffer(_MP3Stream.lpStart,@_MP3Stream.p16,_MP3Stream.lpEnd,_MP3Stream.nReadRest)
      _MP3Stream.nOuts+=_MP3Stream.nReadRest
    end if
  end if
  _MP3Stream.IsStreaming=false
  mad_synth_finish (@_MP3Stream.mSynth )
  mad_frame_finish (@_MP3Stream.mFrame )
  mad_stream_finish(@_MP3Stream.mStream)

  if _MP3Stream.hFile<>0 then close _MP3Stream.hFile:_MP3Stream.hFile=0
end sub

public _
function FBS_Set_StreamVolume(_B Volume as single=1.0) as fbsboolean export
  if _MP3Stream.InUse=false then return false  
  if Volume>2.0    then Volume=2.0
  if Volume<0.0001 then Volume=0.0
  _MP3Stream.Volume=Volume
   return true
end function

public _
function FBS_Get_StreamVolume(_B Volume as single ptr) as fbsboolean export
  if _MP3Stream.InUse=false then return false  
  if Volume=NULL then return false  
  *Volume=_MP3Stream.Volume
   return true
end function

public _
function FBS_Set_StreamPan(_B Pan as single=1.0) as fbsboolean export
  if _MP3Stream.InUse=false then return false  
  if Pan<-1.0 then Pan=-1.0
  if Pan> 1.0 then Pan= 1.0
  _MP3Stream.Pan=Pan
  if Pan>=0.0 then _MP3Stream.rVolume=1 else _MP3Stream.rVolume=Pan+1.0
  if Pan<=0.0 then _MP3Stream.lVolume=1 else _MP3Stream.lVolume=1.0-Pan
   return true
end function

public _
function FBS_Get_StreamPan(_B Pan as single ptr) as fbsboolean export
  if Pan=NULL then return false  
  if _MP3Stream.InUse=false then return false  
  *Pan=_MP3Stream.Pan
   return true
end function

public _
function FBS_Create_MP3Stream (_B Filename as string) as fbsboolean export
  dim as integer i,nBytes,flag,htmp
  if _IsInit         =false then return false   ' not init
  if _MP3Stream.InUse=True  then return false  
  hTmp=freefile()
  if open(Filename for binary access read as #hTmp)<>0 then
    dprint("can't open mp3 stream!")
    return false
  end if

  nBytes=lof(hTmp)
  if (nBytes<0) then
    close hTmp
    dprint ("stream size to short!")
    return false
  end if

  with _MP3Stream
    .InUse=true
    .StreamType = FBS_MP3
    .hFile      = hTmp
    .nInSize    = nBytes
    .IsStreaming= false
    .IsFin      = false
    .hThread    = 0
    .nOuts      = 0
    .nFrames    = 0
    .Volume     = 1.0
    .Pan        = 0.0
    .lVolume    =-1.0
    .rVolume    = 1.0
    .nDecodedSize=0
    .nReadsize  = 0
    .nReadRest  = 0
    .nOutSize=_Plugs(_Plug).Buffersize*3 '!!!
    if (.lpInArray=NULL) then
      .lpInArray=allocate(IN_SIZE+MAD_BUFFER_GUARD)
    end if  
    if (.lpStart=NULL) then
      .lpStart=allocate(.nOutSize)
      .lpEnd=.lpStart+ (.nOutSize)
    end if
    if (.lpBuf=NULL) then 
      .lpBuf=callocate(_Plugs(_Plug).Buffersize+512)
    end if
    if (.lpStreamSamples=NULL) then 
      .lpStreamSamples=callocate(1152*(_Plugs(_Plug).fmt.nBits\8)*_Plugs(_Plug).fmt.nChannels*4)
    end if  
    .lpPlay=.lpStart
    mad_stream_init(@.mStream)
    mad_frame_init (@.mFrame)
    mad_synth_init (@.mSynth)
  end with
   return true
end function

public _
function FBS_Play_MP3Stream (_B Volume  as single=1.0 , _
                        _B Pan     as single=0.0) as fbsboolean export

  if _MP3Stream.InUse=false then return false
  if _MP3Stream.StreamType<>FBS_MP3 then return false
  if (_MP3Stream.IsStreaming=true) then
    dprint("play_mp3stream while IsStreaming=true!")
    fbs_end_mp3stream
  end if

  fbs_Set_StreamVolume Volume
  fbs_Set_StreamPan    Pan
  _MP3Stream.p16    = cptr(short PTR,_MP3Stream.lpStart)
  _MP3Stream.lpPlay =_MP3Stream.lpStart
  _MP3Stream.hThread=ThreadCreate(cptr(any ptr,@_StreamMP3),0)
  if _MP3Stream.hThread=NULL then 
    dprint("play_mp3stream: error ThreadCreate!")
    return false
  else
    while (_MP3Stream.IsStreaming=false)
      sleep 1
    wend
  end if
   return true
end function

function FBS_Get_StreamBuffer(_B lplpBuffer  as short ptr ptr, _
                              _B lpnChannels as integer ptr  , _
                              _B lpnSamples  as integer ptr  ) as fbsboolean export
  if _MP3Stream.InUse=false then return false
  *lplpBuffer  =cptr(short PTR,_MP3Stream.lpPlay)
  *lpnChannels =_Plugs(_Plug).fmt.nChannels
  *lpnSamples=_Plugs(_Plug).Buffersize shr _Plugs(_Plug).fmt.nChannels
   return true
end function

function FBS_End_MP3Stream() as fbsboolean export
  if (_MP3Stream.InUse=false) then return true
  if (_MP3Stream.StreamType<>FBS_MP3) then return false  

  ' end streaming
  _MP3Stream.IsStreaming=false
  if _MP3Stream.hThread<>0 then
    ThreadWait _MP3Stream.hThread
    _MP3Stream.hThread=0
  end if 
  _MP3Stream.InUse=false
   return true
end function


' OGG 
type OGG_BUFFER
  as ubyte ptr pBuffer
  as integer   size
  as integer   index
end type


' file i/o callbacks
private _
function _oggReadcb CDECL (byval pBuffer  as any ptr, _
                       byval ByteSize as integer, _
                       byval nBytes   as integer, _
                       byval pUser    as any ptr) as integer
  dim as OGG_BUFFER ptr  f=cptr(OGG_BUFFER ptr,pUser)
  dim as ubyte ptr pDes=cptr(ubyte ptr,pBuffer)
  dim as ubyte ptr pSrc=f->pBuffer
  dim as integer rest  =f->Size - f->Index

  pSrc+=f->Index
  if nBytes>rest then nBytes=rest
  if nBytes=0 then return 0
  copy(pDes,pSrc,nBytes)
  f->Index+=nBytes
  return nBytes
end function

private _
function _oggSeekcb CDECL (pUser as any ptr,offset as longint,whence as integer) as integer
  dim as OGG_BUFFER ptr  f=cptr(OGG_BUFFER ptr,pUser)
  select case whence
    case 0:f->Index = Offset    ' SEEK_SET
    case 1:f->Index+= Offset    ' SEEK_CUR
    case 2:f->Index = f->Size-1 ' SEEK_END (-1 byte)
  end select
  return f->Index
end function

private _
function _oggClosecb CDECL (pUser as any ptr) as integer
  dim as OGG_BUFFER ptr  f=cptr(OGG_BUFFER ptr,pUser)
  return 1
end function

private _
function _oggTellcb CDECL (pUser as any ptr) as integer
  dim as OGG_BUFFER ptr f =cptr(OGG_BUFFER ptr,pUser)
  return f->index
end function

function FBS_Load_OGGFile(byval Filename as string , _
                          byval lphWave  as integer ptr , _
                          byval tmpfile  as string ="") as fbsboolean export
  static as integer     tmpid=0
  dim as ubyte ptr      lpOGG,pPCM
  dim as integer        hFile,size,ret,section,buffersize
  dim as string         infile,outtmp
  dim as _PCM_FILE_HDR  WaveHdr
  dim as OGG_BUFFER     buf
  dim as OggVorbis_File ovFile
  dim as ov_callbacks   ovCB
  dim as vorbis_info ptr vi

  if lphWave=NULL then return 0
  *lphWave=-1
  if _IsInit=false then return 0

  infile=FileName
  ' read ogg in memory
  hFile=Freefile
  if open(infile for binary access read as #hFile)<>0 then return 0
  size=lof(hFile)
  if size=0     then close #hfile:return 0
  lpOGG=callocate(size)
  if lpOGG=NULL then close #hfile:return 0
  get #hFile,,*lpOGG,size
  close #hFile

  
  ' init callbacks
  with ovCB
    .read_func = @_oggReadcb
    .seek_func = @_oggSeekcb
    .close_func= @_oggClosecb
    .tell_func = @_oggTellcb
  end with

  buf.pBuffer  = lpOGG
  buf.Size     = Size
  ret=ov_open_callbacks(@buf,@ovFile,0,0,ovCB)
  if ret<>0 then
    if (lpOGG<>0) then deallocate lpOGG
    return 0
  end if

  ' get nChannels and sample rate
  vi=ov_info(@ovFile,0)

  ' create temp file
  tmpid+=1
  if tmpfile="" then 
    outtmp="tmpfileogg" & trim(str(tmpid)) & ".wav"
    if len(dir(outtmp)) then kill outtmp
  else
    outtmp=tmpfile
  end if

  hFile=Freefile()
  if open(outtmp for binary access write as #hFile)<>0 then
    if (lpOGG<>NULL) then  deallocate lpOGG:lpOGG=NULL
    ' free ogg file
    ov_clear(@OVFile)
    return 0
  end if

  ' write wave header
  with wavehdr
    .ChunkRIFF     = _RIFF
    .ChunkRIFFSize = sizeof(_PCM_FILE_HDR)-8
    .ChunkID       = _WAVE
    .Chunkfmt      = _fmt
    .ChunkfmtSize  = 16 
    .wFormatTag    = 1
    .nChannels     = vi->channels
    .nRate         = vi->rate
    .nBytesPerSec  = 2 * vi->channels * vi->rate
    .Framesize     = 2 * vi->channels
    .nBits         = 16
    .Chunkdata     = _data
  end with
  put #hFile,,wavehdr

  buffersize = 4096 * 2 * vi->channels
  dim as short pcm(vi->rate * vi->channels)

  dim as integer eFlag
  ret=1
  while (ret>0)
    size=0:pPCM=cptr(ubyte ptr,@pcm(0))
    ' decode one buffer with 4096 samples
    while (size < buffersize)
      ret = ov_read(@ovFile, pPCM + size, buffersize - size, 0, 2, 1, @section)
      if (ret > 0) then
        size += ret
      else
        if (ret < 0) then
          eFlag=1
        else
          exit while
        end if
      end if
    wend
    wavehdr.ChunkRIFFSize+=buffersize
    wavehdr.ChunkdataSize+=buffersize
    put #hFile,,*pPCM,buffersize
  wend
  ret=eflag

  ' write new header in temp.wav and close it
  seek hFile,1
  put #hFile,,wavehdr
  close #hFile

  ' free ov file
  ov_clear(@OVFile)

  ' free memoryfile
  if (lpOGG<>NULL) then deallocate lpOGG:lpOGG=NULL
  ' no error load temp wav
  if ret=0 then
    if FBS_Load_WAVFile(outtmp,lphWave)=true then
      kill outtmp
       return 1
    else
      kill outtmp
      *lphWave=-1
      return 0
    end if
  else
    kill outtmp
    *lphWave=-1
    return 0
  end if
end function

private _
function _IshWave(_B hWave as integer) as fbsboolean
  if (_IsInit=false)                   then return false   ' not init
  if (_nWaves<1)                       then return false   ' no waves loaded
  if (hWave<0) or (hWave>=_nWaves)     then return false   ' no legal hWave
  if _Waves(hWave).lpStart = NULL      then return false   ' reloaded wave
  if _Waves(hWave).nBytes  < 1         then return false   ' reloaded wave
   return true
end function

private _
function _IshSound(_B hSound as integer) as fbsboolean
  if (_IsInit =false)                  then return false   ' not init
  if (_nWaves <1    )                  then return false   ' no waves loaded
  if (_nSounds<1    )                  then return false   ' no sound created
  if (hSound  <0 ) or (hSound>=_nSounds) then return false   ' no legal hSound
  if (_Sounds(hSound).lpStart=NULL)    then return false   ' free old sound
  if (_Sounds(hSound).lpBuf  =NULL)    then return false   ' free old sound
   return true
end function

function FBS_Destroy_Wave(_B lphWave as integer ptr) as fbsboolean export
  dim as integer hWave,hSound
  if (lphWave=NULL) then return false  
  hWave=*lphWave
  if _IshWave(hWave)=false then return false  

  if (_nSounds>0) then
    for hSound=0 to _nSounds-1
      if _IshSound(hSound)=true then
        if _Sounds(hSound).lpStart=_Waves(hWave).lpStart then
          if (_Sounds(hSound).nLoops>0) and (_Sounds(hSound).Paused=false) then 
            _Sounds(hSound).Paused=true
            _Sounds(hSound).nLoops=0
            ' !!! sleep 10 'wait if playing
          end if
          _Sounds(hSound).nLoops=0
          _Sounds(hSound).lpStart=NULL
          if (_Sounds(hSound).lpBuf<>NULL) then
            if (_Sounds(hSound).lpBuf=_Sounds(hSound).lpOrg) then
              deallocate _Sounds(hSound).lpBuf
              _Sounds(hSound).lpBuf=NULL
              _Sounds(hSound).lpOrg=NULL
            else
            ? "!!! pointer value are corrupt !!!"
            end if
          end if
          ' !!! if _Sounds(hSound).lphSound<>NULL then *_Sounds(hSound).lphSound=-1
        end if
      end if
    next
  end if
  if (_Waves(hWave).lpStart<>NULL) then 
    deallocate _Waves(hWave).lpStart
    _Waves(hWave).lpStart=NULL
  end if
  _Waves(hWave).nBytes=0
  *lphWave=-1
   return true
end function

function FBS_Destroy_Sound(_B lphSound as integer ptr) as fbsboolean export
  dim as integer hSound
  if (lphSound=NULL)         then return false  
  hSound=*lphSound
  if _IshSound(hSound)=false then return false  
  if _Sounds(hSound).nLoops>0 then 
    _Sounds(hSound).Paused=true
    _Sounds(hSound).nLoops=0
    ' !!! sleep 100 'wait if playing 
  end if
  _Sounds(hSound).lpStart=NULL
  if (_Sounds(hSound).lpBuf<>NULL) then
    if (_Sounds(hSound).lpBuf=_Sounds(hSound).lpOrg) then
      deallocate _Sounds(hSound).lpBuf
      _Sounds(hSound).lpBuf=NULL
      _Sounds(hSound).lpOrg=NULL
    else
      dprint("!!! pointer value are corrupt !!!")
    end if
  end if  
  'if _Sounds(hSound).lphSound<>NULL then *_Sounds(hSound).lphSound=-1
  *lphSound=-1
   return true
end function

function FBS_Set_SoundSpeed(_B hSound as integer    , _
                       _B Speed  as single=1.0) as fbsboolean export

  if _IshSound(hSound)=false then return false   ' not init

  if Speed>0.0 then
    if Speed<+0.0000015258 then 
      Speed=-0.0000015258
    elseif Speed>16383.0 then
      Speed=16383.0
    end if 
  elseif Speed<0.0 then
    if Speed>-0.0000015258 then 
      Speed=0.0000015258
    elseif Speed<-16383.0 then
      Speed=-16383.0
    end if
  end if
  if speed=0 then speed=1
  _Sounds(hSound).Speed=Speed
   return true
end function

function FBS_Get_SoundSpeed(_B hSound as integer , _
                            _B Speed  as single ptr) as fbsboolean export
  if Speed=NULL then return false  
  if _IshSound(hSound)=false then return false  
  *Speed=_Sounds(hSound).Speed
   return true
end function

function FBS_Set_SoundVolume(_B hSound as integer, _
                             _B Volume as single) as fbsboolean export
  if _IshSound(hSound)=false then return false  
  if Volume>2.0    then Volume=2.0
  if Volume<0.0001 then Volume=0.0
  _Sounds(hSound).Volume=Volume
   return true
end function

function FBS_Get_SoundVolume(_B hSound as integer , _
                             _B Volume as single ptr) as fbsboolean export
  if Volume=NULL then return false  
  if _IshSound(hSound)=false then return false  
  *Volume=_Sounds(hSound).Volume
   return true
end function

function FBS_Set_SoundPan(_B hSound as integer, _
                          _B Pan    as single=1.0) as fbsboolean export
  if _IshSound(hSound)=false then return false
  if Pan<-1.0 then Pan=-1.0
  if Pan> 1.0 then Pan= 1.0
  _Sounds(hSound).Pan=Pan
  if Pan>=0.0 then _Sounds(hSound).rVolume=1 else _Sounds(hSound).rVolume=Pan+1.0
  if Pan<=0.0 then _Sounds(hSound).lVolume=1 else _Sounds(hSound).lVolume=1.0-Pan
   return true
end function

function FBS_Get_SoundPan(_B hSound as integer, _
                          _B Pan as single ptr) as fbsboolean export
  if Pan=NULL then return false  
  if _IshSound(hSound)=false then return false  
  *Pan=_Sounds(hSound).Pan
   return true
end function

function FBS_Set_SoundLoops(_B hSound as integer, _
                            _B nLoops as integer=1) as fbsboolean export
  if _IshSound(hSound)=false   then return false   ' not init
  if nLoops<0 then nLoops=&H7FFFFFFF ' endless !!!
  _Sounds(hSound).nLoops=nLoops
  return true
end function
function FBS_Get_SoundLoops    (_B hSound as integer, _
                                _B nLoops as integer ptr) as fbsboolean export
  if _IshSound(hSound)=false then return false
  if nLoops=NULL             then return false
  *nLoops=_Sounds(hSound).nLoops
  return true
end function

function FBS_Set_SoundMuted(_B hSound as integer, _
                            _B Muted  as fbsboolean) as fbsboolean export
  if _IshSound(hSound)=false   then return false   ' not init
  _Sounds(hSound).Muted=Muted
  return true
end function
function FBS_Get_SoundMuted(_B hSound as integer, _
                            _B Muted  as fbsboolean ptr) as fbsboolean export
  if Muted=NULL                then return false  
  if _IshSound(hSound)=false   then return false  
  *Muted=_Sounds(hSound).Muted
  return true
end function

function FBS_Set_SoundPaused(_B hSound as integer, _
                             _B Paused as fbsboolean) as fbsboolean export
  if _IshSound(hSound)=false    then return false  
  _Sounds(hSound).Paused=Paused
  return true
end function
function FBS_Get_SoundPaused(_B hSound as integer, _
                             _B Paused as fbsboolean ptr) as fbsboolean export
  if _IshSound(hSound)=false then return false
  if (Paused=NULL)           then return false
  *Paused=_Sounds(hSound).Paused
  return true
end function

function fbs_Get_WavePointers(_B hWave         as integer            , _
                              _B lplpWaveStart as short ptr ptr=NULL , _
                              _B lplpWaveEnd   as short ptr ptr=NULL , _
                              _B lpnChannels   as integer ptr  =NULL ) as fbsboolean export
  if _IshWave(hWave)=false then return false
  if (lplpWaveStart<>NULL) then *lplpWaveStart = cptr(short PTR,_Waves(hWave).lpStart)
  if (lplpWaveEnd  <>NULL) then *lplpWaveEnd   = cptr(short PTR,_Waves(hWave).lpStart+_Waves(hWave).nBytes)
  if (lpnChannels  <>NULL) then *lpnChannels   =_Plugs(_Plug).fmt.nChannels
  return true
end function

function fbs_Get_SoundPointers(_B hSound    as integer       , _
                               _B lplpStart as short ptr ptr=NULL , _
                               _B lplpPlay  as short ptr ptr=NULL , _
                               _B lplpEnd   as short ptr ptr=NULL) as fbsboolean export
  if _IshSound(hSound)=false then return false
  if (lplpStart<>NULL) then *lplpStart  =cptr(short PTR,_Sounds(hSound).lpUserStart)
  if (lplpPlay <>NULL) then *lplpPlay   =cptr(short PTR,_Sounds(hSound).lpPlay     )
  if (lplpEnd  <>NULL) then *lplpEnd    =cptr(short PTR,_Sounds(hSound).lpUserEnd  )
  return true
end function



function fbs_Set_SoundPointers( _
  _B hSound     as integer , _
  _B lpNewStart as short ptr=NULL, _
  _B lpNewPlay  as short ptr=NULL, _
  _B lpNewEnd   as short ptr=NULL) as fbsboolean export
  if _IshSound(hSound)=false then return false
  dim as byte ptr lpNew

  ' check start
  if lpNewStart<>NULL then
    lpNew=cptr(byte ptr,lpNewStart)
    if lpNew<_Sounds(hSound).lpStart then
      _Sounds(hSound).lpUserStart=_Sounds(hSound).lpStart
    elseif lpNew>=_Sounds(hSound).lpEnd then
      _Sounds(hSound).lpUserStart=_Sounds(hSound).lpEnd-4
    else
      _Sounds(hSound).lpUserStart=lpNew
    end if
  end if

  ' check end
  if lpNewEnd<>NULL then
    lpNew=cptr(byte ptr,lpNewEnd)
    if lpNew<=_Sounds(hSound).lpStart then
      _Sounds(hSound).lpUserEnd=_Sounds(hSound).lpStart+4
    elseif lpNew>_Sounds(hSound).lpEnd then
      _Sounds(hSound).lpUserEnd=_Sounds(hSound).lpEnd
    else
      _Sounds(hSound).lpUserEnd=lpNew
    end if
  end if
  ' in right oder ?
  if _Sounds(hSound).lpUserStart>_Sounds(hSound).lpUserEnd then
    swap _Sounds(hSound).lpUserStart,_Sounds(hSound).lpUserEnd
  end if

  if lpNewPlay<>NULL then
    lpNew=cptr(byte ptr,lpNewPlay)
    if lpNew<=_Sounds(hSound).lpUserStart then
      _Sounds(hSound).lpPlay=_Sounds(hSound).lpUserStart
    elseif lpNew>_Sounds(hSound).lpUserEnd then
      _Sounds(hSound).lpPlay=_Sounds(hSound).lpUserEnd
    else
      _Sounds(hSound).lpUserEnd=lpNew
    end if
  else
    if _Sounds(hSound).lpPlay>=_Sounds(hSound).lpUserEnd then
      _Sounds(hSound).lpPlay=_Sounds(hSound).lpUserStart
    end if
  end if

  return true
end function


function fbs_Get_WaveLength(_B hWave as integer , _
                       _B lpMS  as integer ptr) as fbsboolean export
   if _IshWave(hWave)=false then return false
   if (lpMS=NULL) then return false
  ' bytes
  *lpMS=_Waves(hWave).nBytes
  ' samples 
  *lpMS\=_Plugs(_Plug).Framesize
  *lpMS*=1000
  *lpMS\=_Plugs(_Plug).Fmt.nRate
   return true
end function

function fbs_Get_SoundLength(_B hSound as integer, _
                             _B lpMS   as integer ptr) as fbsboolean export
  if _IshSound(hSound)=false then return false  
  if (lpMS=NULL) then return false  
  ' bytes
  *lpMS=_Sounds(hSound).lpUserEnd-_Sounds(hSound).lpUserStart
  ' samples
  *lpMS\=_Plugs(_Plug).Framesize
  *lpMS*=1000
  *lpMS\=int(_Sounds(hSound).Speed*_Plugs(_Plug).Fmt.nRate)
  if _Sounds(hSound).nLoops>1 then
    *lpMS*=_Sounds(hSound).nLoops
  endif
   return true
end function

function FBS_Play_Wave(_B hWave  as integer           , _
                       _B nLoops as integer     = 1   , _
                       _B Speed  as single      = 1.0 , _
                       _B Volume as single      = 1.0 , _
                       _B Pan    as single      = 0.0 , _
                       _B hSound as integer ptr = NULL) as fbsboolean export
  dim as integer flag,i
  if _IshWave(hWave)=false then return false ' not a right hWave
  if nLoops<1 then nLoops=&H7FFFFFFF
  if Speed>0.0 then
    if Speed<+0.0000015258 then 
      Speed= -0.0000015258
    elseif Speed>16383.0 then
      Speed=16383.0
    end if  
  elseif Speed<0.0 then
    if Speed>-0.0000015258 then 
      Speed=0.0000015258
    elseif Speed<-16383.0 then
      Speed=-16383.0
    end if
  end if
  if (speed=0.0) then speed=1
  if (pan <-1.0) then pan=-1.0
  if (pan > 1.0) then pan= 1.0
  flag=-1
  if (_nSounds>0) then
    for i=0 to _nSounds-1
      if _Sounds(i).lpStart=NULL then flag=i:exit for
    next
  end if
  if flag=-1 then
    flag=_nSounds
    redim preserve _Sounds(flag)
    _nSounds+=1
  end if
  _Sounds(flag).lpStart     = _Waves(hWave).lpStart
  _Sounds(flag).lpPlay      = _Sounds(flag).lpStart
  _Sounds(flag).lpEnd       = _Sounds(flag).lpStart+_Waves(hWave).nBytes
  ' added user pointers
  _Sounds(flag).lpUserStart = _Sounds(flag).lpStart
  _Sounds(flag).lpUserEnd   = _Sounds(flag).lpEnd

  if _Sounds(flag).lpBuf=NULL then 
    _Sounds(flag).lpBuf = callocate(_Plugs(_Plug).Buffersize+512)
    if (_Sounds(flag).lpBuf=NULL) then
      dprint( "fbs_play_wave: ERROR out of memory!!!")
      sleep :end 1
    else
      _Sounds(flag).lpOrg=_Sounds(flag).lpBuf
    end if
  end if

  _Sounds(flag).Callback       = NULL
  _Sounds(flag).EnabledCallback= false
  _Sounds(flag).nLoops         = nLoops
  _Sounds(flag).Speed          = Speed
  _Sounds(flag).Volume         = Volume
  _Sounds(flag).Paused         = false
  _Sounds(flag).Muted          = false

  FBS_Set_SoundPan(flag,Pan)
  if hSound<>NULL then 
    _Sounds(flag).lphSound   =hSound
    _Sounds(flag).Usercontrol=true
    *hSound=flag
  else
    _Sounds(flag).lphSound   =NULL
    _Sounds(flag).Usercontrol=false
  end if
  return true
end function

function FBS_Create_Sound(_B hWave  as integer  , _
                          _B hSound as integer ptr ) as fbsboolean export
  dim as integer flag,i
  if hSound=NULL           then return false  
  if _IshWave(hWave)=false then return false   ' not a right hWave
  flag=-1
  if _nSounds>0 then
    for i=0 to _nSounds-1
      if _Sounds(i).lpStart=NULL then flag=i:exit for
    next
  end if
  if flag=-1 then
    flag=_nSounds
    redim preserve _Sounds(flag)
    _nSounds+=1
  end if
  _Sounds(flag).lpStart     = _Waves(hWave).lpStart
  _Sounds(flag).lpPlay      = _Waves(hWave).lpStart
  _Sounds(flag).lpEnd       = _Waves(hWave).lpStart+_Waves(hWave).nBytes
  ' added user pointers
  _Sounds(flag).lpUserStart = _Sounds(flag).lpStart
  _Sounds(flag).lpUserEnd   = _Sounds(flag).lpEnd

  if _Sounds(flag).lpBuf=NULL then 
    _Sounds(flag).lpBuf = callocate(_Plugs(_Plug).Buffersize+512)
    if (_Sounds(flag).lpBuf=NULL) then
      dprint("fbs_create_sound: ERROR out of memory!!!")
      sleep :end 1
    else
      _Sounds(flag).lpOrg=_Sounds(flag).lpBuf
    end if
  end if
  _Sounds(flag).Callback       = NULL
  _Sounds(flag).EnabledCallback= false
  _Sounds(flag).nLoops         = 0
  _Sounds(flag).Speed          = 1.0
  _Sounds(flag).Volume         = 1.0
  _Sounds(flag).Paused         = false
  _Sounds(flag).Muted          = false
  FBS_Set_SoundPan(flag,0.0)
  _Sounds(flag).lphSound       = hSound
  _Sounds(flag).Usercontrol    = true
  *hSound=flag
   return true
end function

function FBS_Play_Sound(_B hSound as integer    , _
                        _B nLoops as integer = 1) as fbsboolean export
  if _IshSound(hSound)    = false then return false  
  if nLoops<1 then nLoops = &H7FFFFFFF
  _Sounds(hSound).lpPlay  =_Sounds(hSound).lpStart
  _Sounds(hSound).nLoops  = nLoops
   return true
end function

'  #############################
' # Section of user Callbacks #
'#############################
function FBS_Set_MasterCallback(_B lpCallback as FBS_BUFFERCALLBACK) as fbsboolean export
  if _IsInit=false then return false
  _EnabledCallback=false
  _MasterCallback =lpCallBack
   return true
end function

function FBS_Enable_MasterCallback() as fbsboolean export
  if _IsInit=false        then _EnabledCallback=false:return false
  'if _MasterCallback=NULL then _EnabledCallback=false:return false
  _EnabledCallback=true
   return true
end function

function FBS_Disable_MasterCallback() as fbsboolean export
  if _IsInit=false        then _EnabledCallback=false:return false
  if _MasterCallback=NULL then _EnabledCallback=false:return false
  _EnabledCallback=false
   return true
end function

function FBS_Set_SoundCallback(_B hSound     as integer, _
                               _B lpCallback as FBS_BUFFERCALLBACK) as fbsboolean export
  if _IshSound(hSound)=false then return false  
  _Sounds(hSound).EnabledCallback=false
  _Sounds(hSound).Callback =lpCallBack
   return true
end function

function FBS_Enable_SoundCallback(_B hSound as integer) as fbsboolean export
  if _IshSound(hSound)=false       then return false  
  if _Sounds(hSound).Callback=NULL then return false  
  _Sounds(hSound).EnabledCallback=true
   return true
end function

function FBS_Disable_SoundCallback(_B hSound as integer) as fbsboolean export
  if _IshSound(hSound)=false       then return false  
  if _Sounds(hSound).Callback=NULL then return false  
  _Sounds(hSound).EnabledCallback=false
   return true
end function

function FBS_Set_StreamCallback(_B lpCallback as FBS_BUFFERCALLBACK) as fbsboolean export
  if _MP3Stream.InUse=false   then return false  
  _MP3Stream.EnabledCallback=false
  _MP3Stream.Callback =lpCallBack
   return true
end function

function FBS_Enable_StreamCallback() as fbsboolean export
  if _MP3Stream.InUse=false   then return false  
  if _MP3Stream.Callback=NULL then return false  
  _MP3Stream.EnabledCallback=true
   return true
end function

function FBS_Disable_StreamCallback() as fbsboolean export
  if _MP3Stream.InUse=false   then return false  
  if _MP3Stream.Callback=NULL then return false  
  _MP3Stream.EnabledCallback=false
   return true
end function
