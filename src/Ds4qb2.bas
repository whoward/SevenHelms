'NOTES ON MUSIC SYSTEM
'Playing Background Music
'Syntax:        LoadMusic(MusicName$,MusicType%,MusicChannel%,Repeat%,Enable3d%)
'       MusicName$    -filename of sound
'       MusicType%    - 1 For a MOD file, 2 for an MP3
'       MusicChannel% - Channel name that music will play on (1-5)
'       Repeat%       - 1=Loop Music 2=Play Once
'       Enable3D%     - 1=Enable it, 2= don't (suggest using 1)

'Example Line:  LoadMusic "battle.mp3", 2, 1, 1, 1
'       Means: Load Battle.mp3 file, it is an MP3, use channel 1, loop it, enable 3d audio
'
'Stopping Background Music
'Syntax: RemoveMusic(MusicChannel%)
'       MusicChannel%- Channel that command will clear (1-5)
'
'Example Line: RemoveMusic 1
' Clears all music from channel 1
'
'CHANGING MUSIC VOLUME
'Syntax: SetVolume(MODvol%, SAMvol%, MP3vol%)
'       MODvol% -Volume of MOD files
'       SAMvol% -Sound Effect volume
'       MP3vol% -MP3/WAV volume
'
'Example Line: SetVolume 100, 100, 100
'       Sets all volumes to 100

#Include "Ds4qb2.bi"
#Include "fbsound.bi"

Dim Shared SoundChannels(1 To 5) As Integer = {0, 0, 0, 0, 0}
Dim Shared SoundChannelSounds(1 To 5) As Integer = {0, 0, 0, 0, 0}

Sub CFade (MusicChannel AS INTEGER, FadeStart AS INTEGER, FadeEnd AS INTEGER, FadeSpeed AS INTEGER)
	
End Sub

Sub CPan (MusicChannel AS INTEGER, PanStart AS INTEGER, PanEnd AS INTEGER, PanSpeed AS INTEGER)
	
End Sub

Sub GetFBMOD (MusicChannel AS INTEGER, TotalLength AS LONG, CurrentOrder AS INTEGER, CurrentRow AS INTEGER)
	
End SUB

Sub GetFBMP3 (MusicChannel AS INTEGER, TotalLength AS LONG, CurrentPos AS LONG)
	
End Sub

Sub InitDS4QB
	fbs_Init()
End Sub

Sub LoadMusic (ByVal MusicName AS STRING, ByVal MusicType AS INTEGER, ByVal MusicChannel AS INTEGER, ByVal Repeat AS INTEGER, ByVal Enable3D AS INTEGER)
	Dim As Integer nloops
	
	fbs_Load_MP3File(MusicName, @SoundChannels(MusicChannel))
	
	If Repeat = 1 Then
		nloops = -1
	Else
		nloops = 1
	EndIf
	
	fbs_Play_Wave(SoundChannels(MusicChannel), nloops, , , , @SoundChannelSounds(MusicChannel))
End SUB

Sub LoadSample
	
End SUB

Function LongBreak (LongVar AS LONG, IntNum AS INTEGER) As Integer
	Return 1
End Function

Function LongMake (IntVar1 AS INTEGER, IntVar2 AS INTEGER) As Long
	Return 1
End Function

SUB PlaySample (SFXT As Integer)
	
End Sub

Sub RemoveMusic (ByVal MusicChannel AS Integer)
	fbs_Destroy_Sound(@SoundChannelSounds(MusicChannel))
	fbs_Destroy_Wave(@SoundChannels(MusicChannel))
End Sub

SUB Set3D (MusicChannel AS INTEGER, PX AS SINGLE, PY AS SINGLE, PZ AS SINGLE, VX AS SINGLE, VY AS SINGLE, VZ AS SINGLE)
	
End Sub

SUB SetChannel (MusicChannel AS INTEGER, Frequency AS LONG, Volume AS INTEGER, Panning AS INTEGER)
	
End SUB

SUB SetEAX (EaxCode AS INTEGER)
	
End SUB

SUB SetPos (MusicChannel AS INTEGER, MP3Position AS LONG, MODOrder AS INTEGER, MODRow AS INTEGER)
	
End SUB

SUB SetVolume (MODVol As Integer, SAMVol As Integer, MP3Vol As Integer)
	
End SUB

SUB ShutdownDS4QB
	fbs_Exit()
End Sub

Sub PauseMusic (MusicChannel AS INTEGER)
	
End Sub

Sub ResumeMusic (MusicChannel AS INTEGER)
	
End Sub

Sub WaitforDMA0
	
End Sub

SUB StopSFX (SFXChannel AS INTEGER)
	
End Sub
