'NOTES ON MUSIC SYSTEM
'Playing Background Music
'Syntax:        LoadMusic(MusicName$,MusicType%,MusicChannel%,Repeat%,Enable3d%)
'       MusicName$-filename of sound
'       MusicType%- 1 For a MOD file, 2 for an MP3
'       MusicChannel%- Channel name that music will play on (1-5)
'       Repeat%- 1=Loop Music 2=Play Once
'       Enable3D%- 1=Enable it, 2= don't (suggest using 1)
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
'       MODvol%-Volume of MOD files
'       SAMvol%-Sound Effect volume
'       MP3vol%-MP3/WAV volume
'
'Example Line: SetVolume 100, 100, 100
'       Sets all volumes to 100

'$DYNAMIC
'$INCLUDE: 'DS4QB2.BI'

SUB CFADE (MusicChannel AS INTEGER, FadeStart AS INTEGER, FadeEnd AS INTEGER, FadeSpeed AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MusicChannel
PRINT #1, FadeStart
PRINT #1, FadeEnd
PRINT #1, FadeSpeed
CLOSE #1
OUT &H0, 10
OUT &H0, 10
WaitforDMA0
END Sub

REM $DYNAMIC
SUB CPan (MusicChannel AS INTEGER, PanStart AS INTEGER, PanEnd AS INTEGER, PanSpeed AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MusicChannel
PRINT #1, PanStart
PRINT #1, PanEnd
PRINT #1, PanSpeed
CLOSE #1
OUT &H0, 9
OUT &H0, 9
WaitforDMA0
END Sub

SUB GetFBMOD (MusicChannel AS INTEGER, TotalLength AS LONG, CurrentOrder AS INTEGER, CurrentRow AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MusicChannel
CLOSE #1
OUT &H0, 11
OUT &H0, 11
WaitforDMA0
OPEN "DS4QB2.DAT" FOR BINARY AS #1
GET #1, 1, TotalLength
GET #1, 5, CurrentOrder
GET #1, 7, CurrentRow
CLOSE #1
END SUB

SUB GetFBMP3 (MusicChannel AS INTEGER, TotalLength AS LONG, CurrentPos AS LONG)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MusicChannel
CLOSE #1
OUT &H0, 12
OUT &H0, 12
WaitforDMA0
OPEN "DS4QB2.DAT" FOR BINARY AS #1
GET #1, 1, TotalLength
GET #1, 5, CurrentPos
CLOSE #1
END Sub

REM $STATIC
SUB InitDS4QB
OUT &H0, 0: OUT &H0, 0
END Sub

SUB LoadMusic (MusicName AS STRING, MusicType AS INTEGER, MusicChannel AS INTEGER, Repeat AS INTEGER, Enable3D AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MusicName
PRINT #1, MusicType
PRINT #1, MusicChannel
PRINT #1, Repeat
PRINT #1, Enable3D
CLOSE #1
OUT &H0, 1
OUT &H0, 1
WaitforDMA0
END SUB

SUB LoadSample
WaitforDMA0
OUT &H0, 3
OUT &H0, 3
WaitforDMA0
END SUB

FUNCTION LongBreak% (LongVar AS LONG, IntNum AS INTEGER)
'DIM Offset AS INTEGER, Result AS INTEGER
'DIM Byte1 AS INTEGER, Byte2 AS INTEGER
'
'DEF SEG = VARSEG(LongVar)
'Offset = VARPTR(LongVar)
'Byte1 = PEEK(Offset + IntNum * 2)
'Byte2 = PEEK(Offset + IntNum * 2 + 1)
'DEF SEG = VARSEG(Result)
'Offset = VARPTR(Result)
'POKE Offset, Byte1
'POKE Offset + 1, Byte2
'DEF SEG
'
'LongBreak% = Result
LongBreak% = 0
END FUNCTION

FUNCTION LongMake& (IntVar1 AS INTEGER, IntVar2 AS INTEGER)
'DIM Offset AS INTEGER, Result AS LONG
'DIM Byte1 AS INTEGER, Byte2 AS INTEGER, Byte3 AS INTEGER, Byte4 AS INTEGER
'
'DEF SEG = VARSEG(IntVar1)
'Offset = VARPTR(IntVar1)
'Byte1 = PEEK(Offset)
'Byte2 = PEEK(Offset + 1)
'DEF SEG = VARSEG(IntVar2)
'Offset = VARPTR(IntVar2)
'Byte3 = PEEK(Offset)
'Byte4 = PEEK(Offset + 1)
'DEF SEG = VARSEG(Result)
'Offset = VARPTR(Result)
'POKE Offset, Byte1
'POKE Offset + 1, Byte2
'POKE Offset + 2, Byte3
'POKE Offset + 3, Byte4
'DEF SEG
'
'LongMake& = Result
LongMake& = 0
END FUNCTION

SUB PlaySample (SFXT As Integer)
OUT &H0, SFXT + 55
OUT &H0, SFXT + 55
END Sub

REM $STATIC
SUB RemoveMusic (MusicChannel AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MusicChannel
CLOSE #1
OUT &H0, 2
OUT &H0, 2
WaitforDMA0
END Sub

SUB Set3D (MusicChannel AS INTEGER, PX AS SINGLE, PY AS SINGLE, PZ AS SINGLE, VX AS SINGLE, VY AS SINGLE, VZ AS SINGLE)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MusicChannel
PRINT #1, PX
PRINT #1, PY
PRINT #1, PZ
PRINT #1, VX
PRINT #1, VY
PRINT #1, VZ
CLOSE #1
OUT &H0, 7
OUT &H0, 7
WaitforDMA0
END Sub

SUB SetChannel (MusicChannel AS INTEGER, Frequency AS LONG, Volume AS INTEGER, Panning AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MusicChannel
PRINT #1, Frequency
PRINT #1, Volume
PRINT #1, Panning
CLOSE #1
OUT &H0, 8
OUT &H0, 8
WaitforDMA0
END SUB

SUB SetEAX (EaxCode AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, EaxCode
CLOSE #1
OUT &H0, 5
OUT &H0, 5
WaitforDMA0
END SUB

SUB SetPos (MusicChannel AS INTEGER, MP3Position AS LONG, MODOrder AS INTEGER, MODRow AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR BINARY AS #1
PUT #1, 1, MusicChannel
PUT #1, 5, MP3Position
PUT #1, 9, MODOrder
PUT #1, 11, MODRow
CLOSE #1
OUT &H0, 13
OUT &H0, 13
WaitforDMA0
END SUB

SUB SetVolume (MODVol As Integer, SAMVol As Integer, MP3Vol As Integer)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MODVol
PRINT #1, SAMVol
PRINT #1, MP3Vol
CLOSE #1
OUT &H0, 4
OUT &H0, 4
WaitforDMA0
END SUB

SUB ShutdownDS4QB
RemoveMusic 1
RemoveMusic 2
RemoveMusic 3
RemoveMusic 4
RemoveMusic 5
OUT &H0, 55
END
END Sub

REM $STATIC
SUB PauseMusic (MusicChannel AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MusicChannel
CLOSE #1
OUT &H0, 14
OUT &H0, 14
WaitforDMA0
END Sub

REM $STATIC
SUB ResumeMusic (MusicChannel AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, MusicChannel
CLOSE #1
OUT &H0, 15
OUT &H0, 15
WaitforDMA0
END Sub

REM $STATIC
SUB WaitforDMA0
DO: LOOP UNTIL INP(&H0) = 0
END Sub


SUB StopSFX (SFXChannel AS INTEGER)
WaitforDMA0
OPEN "DS4QB2.DAT" FOR OUTPUT AS #1
PRINT #1, SFXChannel
CLOSE #1
OUT &H0, 6
OUT &H0, 6
WaitforDMA0
END Sub
