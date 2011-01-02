'  #############
' # fscpu.bas #
'#############
' Copyright D.J.Peters (Joshy)

#include "fscpu.bi"

' _DS = declare sub
' _DF = declare function
' _B  = byval

type counter_t             as function () as longint
type zero_t                as sub      (_B d as any ptr                                        ,_B n as integer)
type zerobuffer_t          as sub      (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B n as integer)
type copy_t                as sub      (_B d as any ptr,_B s as any ptr    ,_B n as integer)
type mix16_t               as sub      (_B d as any ptr,_B a as any ptr    ,_B b as any ptr    ,_B n as integer)
type scale16_t             as sub      (_B d as any ptr,_B s as any ptr    ,_B v as single     ,_B n as integer)
type panleft16_t           as sub      (_B d as any ptr,_B s as any ptr    ,_B v as single     ,_B n as integer)
type panright16_t          as sub      (_B d as any ptr,_B s as any ptr    ,_B v as single     ,_B n as integer)
type copyright16_t         as sub      (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B n as integer)
type copyright32_t         as sub      (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B n as integer)
type moveright16_t         as sub      (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B n as integer)
type moveright32_t         as sub      (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B n as integer)
type copysliceright16_t    as sub      (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B v as single,_B n as integer)
type copysliceright32_t    as sub      (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B v as single,_B n as integer)
type movesliceright16_t    as sub      (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B v as single     ,_B n as integer)
type movesliceright32_t    as sub      (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B v as single     ,_B n as integer)
type copysliceleft16_t     as sub      (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B v as single,_B n as integer)
type copysliceleft32_t     as sub      (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B v as single,_B n as integer)
type movesliceleft16_t     as sub      (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B v as single     ,_B n as integer)
type movesliceleft32_t     as sub      (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr,_B v as single     ,_B n as integer)
type CopyMP3Frame_t        as sub      (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B a as any ptr    ,_B n as integer)
type CopySliceMP3Frame32_t as sub      (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B a as any ptr    ,_B v as single     ,_B n as integer)
type CopySliceMP3Frame16_t as sub      (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B a as any ptr    ,_B v as single     ,_B n as integer)
type ScaleMP3Frame_22_16_t as sub      (_B d as any ptr,_B a as any ptr    ,_B b as any ptr    ,_B n as integer)
type ScaleMP3Frame_21_16_t as sub      (_B d as any ptr,_B a as any ptr    ,_B b as any ptr    ,_B n as integer)
type ScaleMP3Frame_12_16_t as sub      (_B d as any ptr,_B a as any ptr    ,_B n as integer)
type ScaleMP3Frame_11_16_t as sub      (_B d as any ptr,_B b as any ptr    ,_B n as integer)
type ShortToInteger_t      as sub      (_B d as any ptr,_B b as any ptr    ,_B n as integer)

_DF _cpucounter            () as longint
_DS _zeroasm               (_B d as any ptr,_B n as integer)
_DS _zerobuffer            (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B n as integer)
_DS _copyasm               (_B d as any ptr,_B s as any ptr    ,_B n as integer)
_DS _copymmx               (_B d as any ptr,_B s as any ptr    ,_B n as integer)
_DS _copysse               (_B d as any ptr,_B s as any ptr    ,_B n as integer)
_DS _mixasm16              (_B d as any ptr,_B a as any ptr    ,_B b as any ptr    ,_B n as integer)
_DS _mixmmx16              (_B d as any ptr,_B a as any ptr    ,_B b as any ptr    ,_B n as integer)
_DS _scaleasm16            (_B d as any ptr,_B s as any ptr    ,_B v as single     ,_B n as integer)
_DS _pan16                 (_B d as any ptr,_B s as any ptr    ,_B l as single     ,_B r as single                      ,_B n as integer)
_DS _copyrightasm16        (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr ,_B l as any ptr ptr,_B n as integer)
_DS _copyrightasm32        (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr ,_B l as any ptr ptr,_B n as integer)
_DS _moverightasm16        (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr                 ,_B n as integer)
_DS _moverightasm32        (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B l as any ptr ptr                 ,_B n as integer)
_DS _copyslicerightasm16   (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr ,_B l as any ptr ptr,_B v as single,_B n as integer)
_DS _copyslicerightasm32   (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr ,_B l as any ptr ptr,_B v as single,_B n as integer)
_DS _copysliceleftasm16    (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr ,_B l as any ptr ptr,_B v as single,_B n as integer)
_DS _copysliceleftasm32    (_B d as any ptr,_B s as any ptr    ,_B p as any ptr ptr,_B e as any ptr ,_B l as any ptr ptr,_B v as single,_B n as integer)
_DS _CopyMP3Frameasm       (_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B f as any ptr                     ,_B n as integer)
_DS _CopySliceMP3Frameasm32(_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B f as any ptr ,_B v as single     ,_B n as integer)
_DS _CopySliceMP3Frameasm16(_B s as any ptr,_B p as any ptr ptr,_B e as any ptr    ,_B f as any ptr ,_B v as single     ,_B n as integer)
_DS _ScaleMP3Frame_22_asm16(_B d as any ptr,_B a as any ptr    ,_B b as any ptr    ,_B n as integer)
_DS _ScaleMP3Frame_21_asm16(_B d as any ptr,_B a as any ptr    ,_B b as any ptr    ,_B n as integer)
_DS _ScaleMP3Frame_12_asm16(_B d as any ptr,_B s as any ptr    ,_B n as integer)
_DS _ScaleMP3Frame_11_asm16(_B d as any ptr,_B s as any ptr    ,_B n as integer)
_DS _ShortToInteger        (_B d as any ptr,_B s as any ptr    ,_B n as integer)

type MMN_CPU
  as sndBoolean  fpu,tsc,cmov,mmx,mmx2,sse,sse2,n3D,n3D2
  as double                start
  as integer               mhz
  as counter_t             cpucounter

  as zero_t                zero
  as zerobuffer_t          zerobuffer 
  as copy_t                copy

  as mix16_t               mix16
  as scale16_t             scale16
  as panleft16_t           panleft16
  as panright16_t          panright16

  as copyright16_t         copyright16
  as copyright32_t         copyright32
  as moveright16_t         moveright16
  as moveright32_t         moveright32

  as copysliceright16_t    copysliceright16
  as copysliceright32_t    copysliceright32
  as movesliceright16_t    movesliceright16
  as movesliceright32_t    movesliceright32

  as copysliceleft16_t     copysliceleft16
  as copysliceleft32_t     copysliceleft32
  as movesliceleft16_t     movesliceleft16
  as movesliceleft32_t     movesliceleft32

  as CopyMP3Frame_t        CopyMP3Frame
  as CopySliceMP3Frame32_t CopySliceMP3Frame32
  as CopySliceMP3Frame16_t CopySliceMP3Frame16
  as ScaleMP3Frame_22_16_t ScaleMP3Frame_22_16
  as ScaleMP3Frame_21_16_t ScaleMP3Frame_21_16
  as ScaleMP3Frame_12_16_t ScaleMP3Frame_12_16
  as ScaleMP3Frame_11_16_t ScaleMP3Frame_11_16
  as ShortToInteger_t      ShortToInteger
end type


private _
sub _zerobas(_B d as any ptr,_B n as integer)
  dim as integer   i
  dim as byte ptr x
  if n<1 then exit sub
  x=cptr(byte ptr,d)
  n-=1
  for i=0 to n
    x[i]=0
  next
end sub


private _
sub _zeroasm(_B d as any ptr,_B n as integer)
  asm
  mov    edi,[d]
  mov    ecx,[n]
  xor    eax,eax
  shr    ecx,1
  jnc    zeroasm_2
  stosb

zeroasm_2:
  shr    ecx,1
  jnc    zeroasm_4
  stosw

zeroasm_4:
  jecxz  zeroasm_end

zeroasm_loop:
  stosd
  dec    ecx
  jnz    zeroasm_loop
zeroasm_end:
  end asm
end sub

private _
sub _ZeroBuffer(_B s as any ptr,_B p as any ptr ptr,_B e as any ptr,_B n as integer)
  asm
  mov esi,[p]
  mov edi,[esi] '*lplpPlay
  mov ecx,[n]
  mov ebx,[s]
  mov edx,[e]
  xor eax,eax
zerobuffer_set:
  mov [edi],al
  inc edi
  cmp edi,edx
  jge zerobuffer_reset
  dec ecx
  jnz zerobuffer_set
  jmp zerobuffer_end

  zerobuffer_reset:
  mov edi,ebx
  dec ecx
  jnz zerobuffer_set

zerobuffer_end:
  mov [esi],edi 'lpPlay=new pos
  end asm
end sub

private _
sub _copybas(_B d as any ptr,_B s as any ptr,_B n as integer)
  dim as integer i
  dim as byte ptr x,y
  if n<1 then exit sub
  n-=1
  x=cptr(byte ptr,d)
  y=cptr(byte ptr,s)
  for i=0 to n
    x[i]=y[i]
  next
end sub

private _
sub _copyasm(_B d as any ptr,_B s as any ptr,_B n as integer)
asm
  mov    edi,dword ptr [d]
  mov    esi,dword ptr [s]
  mov    ecx,dword ptr [n]

  shr    ecx,1
  jnc    copyasm_2
  movsb
  jecxz  copyasm_end

copyasm_2:
  shr    ecx,1
  jnc    copyasm_4
  movsw

copyasm_4:
  jecxz  copyasm_end

copyasm_loop:
  movsd
  dec    ecx
  jnz    copyasm_loop
copyasm_end:
  end asm
end sub

private _
sub _copymmx(_B d as any ptr,_B s as any ptr,_B n as integer)
  asm
  mov   edi,dword ptr [d]
  mov   esi,dword ptr [s]
  mov   ecx,dword ptr [n]

  shr   ecx,1
  jnc   copymmx_2
  movsb

copymmx_2:
  shr   ecx,1
  jnc   copymmx_4
  movsw

copymmx_4:
  shr   ecx,1
  jnc   copymmx_8
  movsd

copymmx_8:
  shr   ecx,1
  jnc   copymmx_16
  movq  mm0,[esi]
  movq  [edi],mm0
  add   esi,8
  add   edi,8

copymmx_16:
  shr   ecx,1
  jnc   copymmx_32
  movq  mm0,[esi]
  movq  [edi],mm0
  movq  mm0,[esi+8]
  movq  [edi+8],mm0
  lea   esi,[esi+16]
  lea   edi,[edi+16]

copymmx_32:
  shr   ecx,1
  jnc   copymmx_64
  movq  mm0,[esi]
  movq  [edi],mm0
  movq  mm0,[esi+8]
  movq  [edi+8],mm0
  movq  mm0,[esi+16]
  movq  [edi+16],mm0
  movq  mm0,[esi+24]
  movq  [edi+24],mm0
  lea   esi,[esi+32]
  lea   edi,[edi+32]

copymmx_64:
  jecxz copymmx_end

  copymmx_loop:
    movq   mm0,[esi]
    movq   [edi   ],mm0
    movq   mm1,[esi+ 8]
    movq   [edi+ 8],mm1
    movq   mm2,[esi+16]
    movq   [edi+16],mm2
    movq   mm3,[esi+24]
    movq   [edi+24],mm3
    movq   mm4,[esi+32]
    movq   [edi+32],mm4
    movq   mm5,[esi+40]
    movq   [edi+40],mm5
    movq   mm6,[esi+48]
    movq   [edi+48],mm6
    movq   mm7,[esi+56]
    movq   [edi+56],mm7
    lea    esi,[esi+64]
    lea    edi,[edi+64]
    dec ecx
  jnz copymmx_loop

  copymmx_end:
  emms
end asm
end sub

private _
sub _copysse(_B d as any ptr,_B s as any ptr,_B n as integer)
  asm
  mov   edi,dword ptr [d]
  mov   esi,dword ptr [s]
  mov   ecx,dword ptr [n]

  shr   ecx,1
  jnc   copysse_2
  movsb

copysse_2:
  shr   ecx,1
  jnc   copysse_4
  movsw

copysse_4:
  shr   ecx,1
  jnc   copysse_8
  movsd

copysse_8:
  shr   ecx,1
  jnc   copysse_16
  movq  mm0,[esi  ]
  movq  [edi],mm0
  lea   esi,[esi+8]
  lea   edi,[edi+8]

copysse_16:
  shr   ecx,1
  jnc   copysse_32
  movq  mm0,[esi   ]
  movq  [edi  ],mm0
  movq  mm0,[esi+ 8]
  movq  [edi+8],mm0
  lea   esi,[esi+16]
  lea   edi,[edi+16]

copysse_32:
  shr   ecx,1
  jnc   copysse_64
  movq  mm0,[esi   ]
  movq  [edi  ],mm0
  movq  mm0,[esi+ 8]
  movq  [edi+8],mm0
  movq  mm0,[esi+16]
  movq  [edi+16],mm0
  movq  mm0,[esi+24]
  movq  [edi+24],mm0
  lea   esi,[esi+32]
  lea   edi,[edi+32]

copysse_64:
  jecxz copysse_end
  copysse_loop:
    movq   mm0,[esi+ 0]
    movntq [edi+ 0],mm0
    movq   mm1,[esi+ 8]
    movntq [edi+ 8],mm1
    movq   mm2,[esi+16]
    movntq [edi+16],mm2
    movq   mm3,[esi+24]
    movntq [edi+24],mm3
    movq   mm4,[esi+32]
    movntq [edi+32],mm4
    movq   mm5,[esi+40]
    movntq [edi+40],mm5
    movq   mm6,[esi+48]
    movntq [edi+48],mm6
    movq   mm7,[esi+56]
    movntq [edi+56],mm7
    lea    esi,[esi+64]
    lea    edi,[edi+64]
    dec ecx
  jnz copysse_loop

  copysse_end:
  emms
  end asm
end sub

private _
sub _mixasm16(_B d as any ptr,_B a as any ptr,_B b as any ptr,_B n as integer)
  asm
  mov edi,dword ptr[d]
  mov esi,dword ptr[a]
  mov ebx,dword ptr[b]
  mov ecx,dword ptr[n]
  xor edx,edx

mixasm16loop:
  mov ax, word ptr [esi+edx] ' chna
  add ax, word ptr [ebx+edx] ' chnb
  jo mixasm16testc
  mov word ptr [edi+edx],ax
  add edx,2
  cmp edx,ecx
  jb  mixasm16loop
  jmp mixasm16end

mixasm16testc:
  jc  mixasm16savemin
  mov word ptr [edi+edx],&H7FFF ' +32767
  add edx,2
  cmp edx,ecx
  jb  mixasm16loop
  jmp mixasm16end

mixasm16savemin:
  mov word ptr [edi+edx],&H8000 ' -32768
  add edx,2
  cmp edx,ecx
  jb mixasm16loop
mixasm16end:
  end asm
end sub

private _
sub _mixmmx16(_B d as any ptr,_B a as any ptr,_B b as any ptr,_B n as integer)
asm
  mov  edi,dword ptr [d]
  mov  esi,dword ptr [a]
  mov  ebx,dword ptr [b]
  mov  ecx,dword ptr [n]
  sub  ecx,8
  xor  edx,edx
  jmp  mixmmx16loop

mixmmx16add:
  add    edx, 8
mixmmx16loop:
  movq   mm0, [esi+edx] '     chna 4 words
  paddsw mm0, [ebx+edx] ' add chnb 4 words
  movq   [edi + edx], mm0
  cmp    edx, ecx
  jb     mixmmx16add
  emms
end asm
end sub

private _
sub _scaleasm16(_B d as any ptr,_B s as any ptr,_B v as single,_B n as integer)
  dim mul32 as integer = (1 shl 16)
  asm
  fild   dword ptr [mul32]
  fld    dword ptr [v]
  fmulp
  fistp  dword ptr [mul32]

  mov    edi,[d]
  mov    esi,[s]
  mov    ecx,[n]
  sub    ecx,2

  push   ebp
  mov    ebp,dword ptr [mul32]
  xor    ebx,ebx
  jmp    scaleasm16_start

scaleasm16_add:
  add    ebx,2
scaleasm16_start:
  movsx  eax,word ptr [esi+ebx]
  imul   ebp
  jo     scaleasm16_min
  shr    eax,16
  mov    word ptr [edi+ebx],ax
  cmp    ebx,ecx
  jb     scaleasm16_add
  jmp    scaleasm16_end

scaleasm16_min:
  and    edx,edx
  jz     scaleasm16_max
  mov    word ptr [edi+ebx],&H8000 ' -32768
  cmp    ebx,ecx
  jb     scaleasm16_add
  jmp    scaleasm16_end

scaleasm16_max:
  mov    word ptr [edi+ebx],&H7fff ' +32767
  cmp    ebx,ecx
  jb     scaleasm16_add

scaleasm16_end:
  pop ebp
  end asm
end sub

private _
sub _panleftasm16(_B d as any ptr,_B s as any ptr,_B l as single,_B n as integer)
  dim mul32 as integer = l*(1 shl 16)
  asm
  mov    edi,[d]
  mov    esi,[s]
  mov    ecx,[n]
  sub    ecx,4

  push   ebp
  mov    ebp,dword ptr [mul32]
  xor    ebx,ebx
  jmp    panleftasm16_start

panleftasm16_add:
  add    ebx,4
panleftasm16_start:
  movsx  eax,word ptr [esi+ebx] ' get left
  imul   ebp                    ' scale left
  jo     panleftasm16_min
  shr    eax,16
  mov    [edi+ebx],ax           ' set left
  mov    ax,[esi+ebx+2]         ' get right  
  mov    [edi+ebx+2],ax         ' set right
  cmp    ebx,ecx
  jb     panleftasm16_add
  jmp    panleftasm16_end

panleftasm16_min:
  and    edx,edx
  jz     panleftasm16_max
  mov    word ptr [edi+ebx],&H8000 ' -32768 set left
  mov    ax,[esi+ebx+2]            ' get right  
  mov    [edi+ebx+2],ax            ' set right
  cmp    ebx,ecx
  jb     panleftasm16_add
  jmp    panleftasm16_end

panleftasm16_max:
  mov    word ptr [edi+ebx],&H7fff ' +32767 set left
  mov    ax,[esi+ebx+2]            ' get right  
  mov    [edi+ebx+2],ax            ' set right
  cmp    ebx,ecx
  jb     panleftasm16_add

panleftasm16_end:
  pop ebp
  end asm
end sub

private _
sub _panrightasm16(_B d as any ptr,_B s as any ptr,_B r as single,_B n as integer)
  dim mul32 as integer = r*(1 shl 16)
  asm
  mov    edi,[d]
  mov    esi,[s]
  mov    ecx,[n]
  sub    ecx,4

  push   ebp
  mov    ebp,dword ptr [mul32]
  xor    ebx,ebx
  jmp    panrightasm16_start

panrightasm16_add:
  add    ebx,4
panrightasm16_start:
  movsx  eax,word ptr [esi+ebx+2] ' get right
  imul   ebp                    ' scale right
  jo     panrightasm16_min
  shr    eax,16
  mov    [edi+ebx+2],ax         ' set right
  mov    ax,[esi+ebx]           ' get left  
  mov    [edi+ebx],ax           ' set left
  cmp    ebx,ecx
  jb     panrightasm16_add
  jmp    panrightasm16_end

panrightasm16_min:
  and    edx,edx
  jz     panrightasm16_max
  mov    word ptr [edi+ebx+2],&H8000 ' -32768 set right
  mov    ax,[esi+ebx]            ' get left  
  mov    [edi+ebx],ax            ' set left
  cmp    ebx,ecx
  jb     panrightasm16_add
  jmp    panrightasm16_end

panrightasm16_max:
  mov    word ptr [edi+ebx+2],&H7fff ' +32767 set right
  mov    ax,[esi+ebx]            ' get left  
  mov    [edi+ebx],ax            ' set left
  cmp    ebx,ecx
  jb     panrightasm16_add

panrightasm16_end:
  pop ebp
  end asm
end sub

private _
function _ReadEFLAG() as uinteger
  asm pushfd  'eflag on stack
  asm pop eax 'in eax
  asm mov [function],eax
end function

private _
sub _WriteEFLAG(_B v as uinteger)
  asm mov eax,[v]
  asm push eax 'value on stack
  asm popfd    'pop in eflag
end sub

private _
function _IsCPUID() as sndBoolean 'CPUID command aviable
  dim as uinteger _old,_new
  _old = _readeflag()
  _new = _old xor &H200000 'change bit 21
  _writeeflag _new
  _new = _readeflag()
  if _old<>_new then
    function = true
    _writeeflag _old 'restore old value
  end if
end function 

private _
function _IsFPU() as sndBoolean 'FPU aviable
  dim as ushort tmp
  tmp = &HFFFF
  asm fninit 'try FPU init
  asm fnstsw [tmp] 'store statusword
  if tmp=0 then 'is it really 0
    asm fnstcw [tmp] 'store control
    if tmp=&H37F then function = true
  end if
end function 

private _
function _TSC() as longint
  dim tmp as longint
  asm RDTSC
  asm mov [tmp  ],eax
  asm mov [tmp+4],edx
  function = tmp
end function 

private _
function _CPUIDEAX(_B nr as integer) as integer
  asm mov dword ptr eax,[nr]
  asm cpuid
  asm mov [function],eax
end function 

private _
function _CPUIDEDX(_B nr as integer) as integer
  asm mov dword ptr eax,[nr]
  asm cpuid
  asm mov [function],edx
end function 

'  ###############
' # 16 bit mono #
'###############
private _
sub _copyrightasm16(_B d as any ptr,_B s as any ptr,_B p as any ptr ptr,_B e as any ptr,_B l as any ptr ptr,_B n as integer)
  dim as integer loops
  asm
  mov edi,[d] 
  mov esi,[l]
  mov esi,[esi] ' *l
  mov [loops],esi
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,1 ' bytes to words
  mov ebx,[s]
  mov edx,[e]
  and edx,&HFFFFFFFE

  copy_right_asm16_get:
    mov ax,[esi]
    mov [edi],ax
    add edi,2
    add esi,2
    cmp esi,edx
    jge copy_right_asm16_reset
    dec ecx
    jnz copy_right_asm16_get
    jmp copy_right_asm16_end

  copy_right_asm16_reset:
    dec dword ptr [loops]
    jz  copy_right_asm16_fill 
    sub esi,edx
    add esi,ebx
    dec ecx
    jnz copy_right_asm16_get
    jmp copy_right_asm16_end

copy_right_asm16_fill:
  xor ax,ax
copy_right_asm16_fillloop:
  mov [edi],ax
  add edi,2
  dec ecx
  jnz copy_right_asm16_fillloop

copy_right_asm16_end:
  mov edi,[p]
  mov [edi],esi
  mov edi,[l]
  mov eax,[loops]
  mov [edi],eax
  end asm
end sub

private _
sub _moverightasm16(_B s as any ptr,_B p as any ptr ptr,_B e as any ptr,_B l as any ptr ptr,_B n as integer)
  dim as integer loops
  asm
  mov esi,[l]
  mov edi,[esi] ' *l
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,1 ' bytes to words
  mov ebx,[s]
  mov edx,[e]
  and edx,&HFFFFFFFE

  move_right_asm16_get:
    add esi,2
    cmp esi,edx
    jge move_right_asm16_reset
    dec ecx
    jnz move_right_asm16_get
    jmp move_right_asm16_end

  move_right_asm16_reset:
    dec edi
    jz  move_right_asm16_end 
    sub esi,edx
    add esi,ebx
    dec ecx
    jnz move_right_asm16_get

move_right_asm16_end:
  mov eax,[p]
  mov [eax],esi
  mov eax,[l]
  mov [eax],edi
  end asm
end sub

private _
sub _copyslicerightasm16(_B d as any ptr,_B s as any ptr,_B p as any ptr ptr,_B e as any ptr,_B l as any ptr ptr,_B v as single,_B n as integer)
  dim as integer loops,speed
  speed=abs(v*(1 shl 16))
  asm
  mov edi,[d] 
  mov esi,[l]
  mov esi,[esi] ' *l
  mov [loops],esi
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,1 ' bytes to words
  xor ebx,ebx

  copy_sliceright_asm16_get:
    mov ax,[esi]
  copy_sliceright_asm16_set:
    mov [edi],ax
    add edi,2
    add ebx,dword ptr [speed] ' value+=step
    mov edx,ebx
    and ebx,&HFFFF
    shr edx,15     ' words
    and edx,&HFFFE
    jnz copy_sliceright_asm16_add
    dec ecx
    jnz copy_sliceright_asm16_set
    jmp copy_sliceright_asm16_end

  copy_sliceright_asm16_add:
    add esi,edx    ' add only N*2 (words)
    mov eax,[e]
    and eax,&HFFFFFFFE
    cmp esi,eax
    jge copy_sliceright_asm16_reset
    dec ecx
    jnz copy_sliceright_asm16_get
    jmp copy_sliceright_asm16_end

  copy_sliceright_asm16_reset:
    dec dword ptr [loops]
    jz  copy_sliceright_asm16_fill 
    sub esi,eax
    add esi,dword ptr [s]
    dec ecx
    jnz copy_sliceright_asm16_get
    jmp copy_sliceright_asm16_end

copy_sliceright_asm16_fill:
  xor ax,ax
copy_sliceright_asm16_fillloop:
  mov [edi],ax
  add edi,2
  dec ecx
  jnz copy_sliceright_asm16_fillloop

copy_sliceright_asm16_end:
  mov edi,[p]
  mov [edi],esi
  mov edi,[l]
  mov eax,[loops]
  mov [edi],eax
  end asm
end sub

private _
sub _copysliceleftasm16(_B d as any ptr,_B s as any ptr,_B p as any ptr ptr,_B e as any ptr,_B l as any ptr ptr,_B v as single,_B n as integer)
  dim as integer loops,speed
  speed=abs(v*(1 shl 16))
  asm
  mov edi,[d] 
  mov esi,[l]
  mov esi,[esi] ' *l
  mov [loops],esi
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,1 ' bytes to words
  xor ebx,ebx

  copy_sliceleft_asm16_get:
    mov ax,[esi]
  copy_sliceleft_asm16_set:
    mov [edi],ax
    add edi,2
    add ebx,dword ptr [speed] ' value+=step
    mov edx,ebx
    and ebx,&HFFFF
    shr edx,15     ' words
    and edx,&HFFFE
    jnz copy_sliceleft_asm16_sub
    dec ecx
    jnz copy_sliceleft_asm16_set
    jmp copy_sliceleft_asm16_end

  copy_sliceleft_asm16_sub:    
    sub esi,edx    ' sub only N*4 (dwords)
    mov eax,[s]
    and eax,&HFFFFFFFE
    cmp esi,eax
    jle copy_sliceleft_asm16_reset
    dec ecx
    jnz copy_sliceleft_asm16_get
    jmp copy_sliceleft_asm16_end

  copy_sliceleft_asm16_reset:
    dec dword ptr [loops]
    jz  copy_sliceleft_asm16_fill 
    sub esi,eax
    add esi,dword ptr [e]
    dec ecx
    jnz copy_sliceleft_asm16_get
    jmp copy_sliceleft_asm16_end

copy_sliceleft_asm16_fill:
  xor ax,ax
copy_sliceleft_asm16_fillloop:
  mov [edi],ax
  add edi,2
  dec ecx
  jnz copy_sliceleft_asm16_fillloop

copy_sliceleft_asm16_end:
  mov edi,[p]
  mov [edi],esi
  mov edi,[l]
  mov eax,[loops]
  mov [edi],eax
  end asm
end sub

private _
sub _moveslicerightasm16(_B s as any ptr,_B p as any ptr ptr,_B e as any ptr,_B l as any ptr ptr,_B v as single,_B n as integer)
  dim as integer loops,speed
  speed=abs(v*(1 shl 16))
  asm
  mov edi,[e]
  and edi,&HFFFFFFFE 
  mov esi,[l]
  mov esi,[esi] ' *l
  mov [loops],esi
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,1 ' bytes to words
  mov edx,[speed]
  xor ebx,ebx

  move_sliceright_asm16_get:
    add ebx,edx
    mov eax,ebx
    and ebx,&HFFFF
    shr eax,15     ' words
    and eax,&HFFFE
    jnz move_sliceright_asm16_add
    dec ecx
    jnz move_sliceright_asm16_get
    jmp move_sliceright_asm16_end

  move_sliceright_asm16_add:    
    add esi,eax    ' add only N*2 (words)
    cmp esi,edi
    jge move_sliceright_asm16_reset
    dec ecx
    jnz move_sliceright_asm16_get
    jmp move_sliceright_asm16_end

  move_sliceright_asm16_reset:
    dec dword ptr [loops]
    jz  move_sliceright_asm16_end 
    sub esi,edi
    add esi,dword ptr [s]
    dec ecx
    jnz move_sliceright_asm16_get

move_sliceright_asm16_end:
  mov edi,[p]
  mov [edi],esi
  mov edi,[l]
  mov eax,[loops]
  mov [edi],eax
  end asm
end sub

private _
sub _movesliceleftasm16(_B s as any ptr,_B p as any ptr ptr,_B e as any ptr,_B l as any ptr ptr,_B v as single,_B n as integer)
  dim as integer loops,speed
  speed=abs(v*(1 shl 16))
  asm
  mov edi,[s]
  and edi,&HFFFFFFFE  
  mov esi,[l]
  mov esi,[esi] ' *l
  mov [loops],esi
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,1 ' bytes to words
  mov edx,[speed]
  xor ebx,ebx

  move_sliceleft_asm16_get:
    add ebx,edx ' value+=step
    mov eax,ebx
    and ebx,&HFFFF
    shr eax,15     ' words
    and eax,&HFFFE
    jnz move_sliceleft_asm16_sub
    dec ecx
    jnz move_sliceleft_asm16_get
    jmp move_sliceleft_asm16_end

  move_sliceleft_asm16_sub:    
    sub esi,eax    ' sub only N*2 (words)
    cmp esi,edi
    jle move_sliceleft_asm16_reset
    dec ecx
    jnz move_sliceleft_asm16_get
    jmp move_sliceleft_asm16_end

  move_sliceleft_asm16_reset:
    dec dword ptr [loops]
    jz  move_sliceleft_asm16_end 
    sub esi,edi
    add esi,dword ptr [e]
    dec ecx
    jnz move_sliceleft_asm16_get

move_sliceleft_asm16_end:
  mov edi,[p]
  mov [edi],esi
  mov edi,[l]
  mov eax,[loops]
  mov [edi],eax
  end asm
end sub

'  ########################
' # 32 bit 16 bit stereo #
'########################
private _
sub _copyrightasm32(_B d as any ptr,_B s as any ptr,_B p as any ptr ptr,_B e as any ptr,_B l as any ptr ptr,_B n as integer)
  dim as integer loops
  asm
  mov edi,[d] 
  mov esi,[l]
  mov esi,[esi] ' *l
  mov [loops],esi
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,2 ' bytes to dwords
  mov ebx,[s]
  mov edx,[e]
  and edx,&HFFFFFFFC

  copy_right_asm32_get:
    mov eax,[esi]
    mov [edi],eax
    add edi,4
    add esi,4
    cmp esi,edx
    jge copy_right_asm32_reset
    dec ecx
    jnz copy_right_asm32_get
    jmp copy_right_asm32_end

  copy_right_asm32_reset:
    dec dword ptr [loops]
    jz  copy_right_asm32_fill 
    sub esi,edx
    add esi,ebx
    dec ecx
    jnz copy_right_asm32_get
    jmp copy_right_asm32_end

copy_right_asm32_fill:
  xor eax,eax
copy_right_asm32_fillloop:
  mov [edi],eax
  add edi,4
  dec ecx
  jnz copy_right_asm32_fillloop

copy_right_asm32_end:
  mov edi,[p]
  mov [edi],esi
  mov edi,[l]
  mov eax,[loops]
  mov [edi],eax
  end asm
end sub

private _
sub _moverightasm32(_B s as any ptr,_B p as any ptr ptr,_B e as any ptr,_B l as any ptr ptr,_B n as integer)
  dim as integer loops
  asm
  mov esi,[l]
  mov edi,[esi] ' *l
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,2 ' bytes to dwords
  mov ebx,[s]
  mov edx,[e]
  and edx,&HFFFFFFFC

  move_right_asm32_get:
    add esi,4
    cmp esi,edx
    jge move_right_asm32_reset
    dec ecx
    jnz move_right_asm32_get
    jmp move_right_asm32_end

  move_right_asm32_reset:
    dec edi
    jz  move_right_asm32_end 
    sub esi,edx
    add esi,ebx
    dec ecx
    jnz move_right_asm32_get

move_right_asm32_end:
  mov eax,[p]
  mov [eax],esi
  mov eax,[l]
  mov [eax],edi
  end asm
end sub

private _
sub _copyslicerightasm32(_B d as any ptr    , _
                         _B s as any ptr    , _
                         _B p as any ptr ptr, _
                         _B e as any ptr    , _
                         _B l as any ptr ptr, _
                         _B v as single     , _
                         _B n as integer    )
  dim as integer loops,speed
  speed=abs(v*(1 shl 16)) ' single to fixrd point 16.16
  asm
  mov edi,[d]     ' destination buffer 
  mov esi,[l]     ' lplp loops
  mov esi,[esi]   ' *l get nLoops from ptr
  mov [loops],esi ' save in local var loops
  mov esi,[p]     ' lplp ´playpointer
  mov esi,[esi]   ' *p playpos in esi
  mov ecx,[n]     ' get nbytes
  shr ecx,2       ' bytes to dwords
  xor ebx,ebx     ' temp var value

  copy_sliceright_asm32_get:
    mov eax,[esi]  ' get samples from wave buffer
  copy_sliceright_asm32_set:
    mov [edi],eax  ' put in destination buffer
    add edi,4      ' address next pos in des buffer
    add ebx,dword ptr [speed] ' value+=step
    mov edx,ebx               ' save value
    and ebx,&HFFFF            ' value=value and 0000:FFFF
    shr edx,14                ' dwords
    and edx,&HFFFC
    jnz copy_sliceright_asm32_add
    dec ecx
    jnz copy_sliceright_asm32_set
    jmp copy_sliceright_asm32_end

  copy_sliceright_asm32_add:
    add esi,edx    ' add only N*4 (dwords)
    mov eax,[e]
    and eax,&HFFFFFFFC
    cmp esi,eax
    jge copy_sliceright_asm32_reset
    dec ecx
    jnz copy_sliceright_asm32_get
    jmp copy_sliceright_asm32_end

  copy_sliceright_asm32_reset:
    dec dword ptr [loops]
    jz  copy_sliceright_asm32_fill 
    sub esi,eax
    add esi,dword ptr [s]
    dec ecx
    jnz copy_sliceright_asm32_get
    jmp copy_sliceright_asm32_end

copy_sliceright_asm32_fill:
  xor eax,eax
copy_sliceright_asm32_fillloop:
  mov [edi],eax
  add edi,4
  dec ecx
  jnz copy_sliceright_asm32_fillloop

copy_sliceright_asm32_end:
  mov edi,[p]
  mov [edi],esi
  mov edi,[l]
  mov eax,[loops]
  mov [edi],eax
  end asm
end sub

private _
sub _CopySliceLeftasm32(_B d as any ptr    , _
                        _B s as any ptr    , _
                        _B p as any ptr ptr, _
                        _B e as any ptr    , _
                        _B l as any ptr ptr, _
                        _B v as single     , _
                        _B n as integer)
  dim as integer loops,speed
  v=abs(v)
  speed=v*(1 shl 16)
  asm
  mov edi,[d]
  mov esi,[l]
  mov esi,[esi] ' *l
  mov [loops],esi
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,2 ' bytes to dwords
  'dec ecx ' !!! nonthens !!!
  xor ebx,ebx

  copy_sliceleft_asm32_get:
    mov eax,[esi]
  copy_sliceleft_asm32_set:
    mov [edi],eax
    add edi,4
    add ebx,dword ptr [speed] ' value+=step
    mov edx,ebx
    and ebx,&HFFFF
    shr edx,14     ' dwords
    and edx,&HFFFC
    jnz copy_sliceleft_asm32_sub
    dec ecx
    jnz copy_sliceleft_asm32_set
    jmp copy_sliceleft_asm32_end

  copy_sliceleft_asm32_sub:
    sub esi,edx    ' sub only N*4 (dwords)
    mov eax,[s]
    and eax,&HFFFFFFFC
    cmp esi,eax
    jle copy_sliceleft_asm32_reset
    dec ecx
    jnz copy_sliceleft_asm32_get
    jmp copy_sliceleft_asm32_end

  copy_sliceleft_asm32_reset:
    dec dword ptr [loops]
    jz  copy_sliceleft_asm32_fill 
    sub esi,eax
    add esi,dword ptr [e]
    dec ecx
    jnz copy_sliceleft_asm32_get
    jmp copy_sliceleft_asm32_end

copy_sliceleft_asm32_fill:
  xor eax,eax
copy_sliceleft_asm32_fillloop:
  mov [edi],eax
  add edi,4
  dec ecx
  jnz copy_sliceleft_asm32_fillloop

copy_sliceleft_asm32_end:
  mov edi,[p]
  mov [edi],esi
  mov edi,[l]
  mov eax,[loops]
  mov [edi],eax
  end asm
end sub

private _
sub _MoveSliceRightasm32(_B s as any ptr    , _
                         _B p as any ptr ptr, _
                         _B e as any ptr    , _
                         _B l as any ptr ptr, _
                         _B v as single     , _
                         _B n as integer)
  dim as integer loops,speed
  speed=abs(v*(1 shl 16))
  asm
  mov edi,[e]
  and edi,&HFFFFFFFC 
  mov esi,[l]
  mov esi,[esi] ' *l
  mov [loops],esi
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,2 ' bytes to dwords

  mov edx,[speed]
  xor ebx,ebx

  move_sliceright_asm32_get:
    add ebx,edx
    mov eax,ebx
    and ebx,&HFFFF
    shr eax,14     ' dwords
    and eax,&HFFFC
    jnz move_sliceright_asm32_add
    dec ecx
    jnz move_sliceright_asm32_get
    jmp move_sliceright_asm32_end

  move_sliceright_asm32_add:
    add esi,eax    ' add only N*4 (dwords)
    cmp esi,edi
    jge move_sliceright_asm32_reset
    dec ecx
    jnz move_sliceright_asm32_get
    jmp move_sliceright_asm32_end

  move_sliceright_asm32_reset:
    dec dword ptr [loops]
    jz  move_sliceright_asm32_end 
    sub esi,edi
    add esi,dword ptr [s]
    dec ecx
    jnz move_sliceright_asm32_get

move_sliceright_asm32_end:
  mov edi,[p]
  mov [edi],esi
  mov edi,[l]
  mov eax,[loops]
  mov [edi],eax
  end asm
end sub

private _
sub _MoveSliceLeftasm32(_B s as any ptr    , _
                        _B p as any ptr ptr, _
                        _B e as any ptr    , _
                        _B l as any ptr ptr, _
                        _B v as single     , _
                        _B n as integer)
  dim as integer loops,speed
  speed=abs(v*(1 shl 16))
  asm
  mov edi,[s]
  and edi,&HFFFFFFFC  
  mov esi,[l]
  mov esi,[esi] ' *l
  mov [loops],esi
  mov esi,[p]
  mov esi,[esi] ' *p
  mov ecx,[n]
  shr ecx,2 ' bytes to dwords
  mov edx,[speed]
  xor ebx,ebx

  move_sliceleft_asm32_get:
    add ebx,edx ' value+=step
    mov eax,ebx
    and ebx,&HFFFF
    shr eax,14     ' dwords
    and eax,&HFFFC
    jnz move_sliceleft_asm32_sub
    dec ecx
    jnz move_sliceleft_asm32_get
    jmp move_sliceleft_asm32_end

  move_sliceleft_asm32_sub:    
    sub esi,eax    ' sub only N*4 (dwords)
    cmp esi,edi
    jle move_sliceleft_asm32_reset
    dec ecx
    jnz move_sliceleft_asm32_get
    jmp move_sliceleft_asm32_end

  move_sliceleft_asm32_reset:
    dec dword ptr [loops]
    jz  move_sliceleft_asm32_end 
    sub esi,edi
    add esi,dword ptr [e]
    dec ecx
    jnz move_sliceleft_asm32_get

move_sliceleft_asm32_end:
  mov edi,[p]
  mov [edi],esi
  mov edi,[l]
  mov eax,[loops]
  mov [edi],eax
  end asm
end sub

private _
sub _CopyMP3Frameasm(_B lpStart   as any ptr , _
                     _B lplpPlay  as any ptr ptr, _
                     _B lpEnd     as any ptr , _
                     _B lpSamples as any ptr , _ 
                     _B nBytes    as integer  )
  asm
  mov esi,[lpSamples]
  mov edi,[lplpPlay]
  mov edi,[edi] 
  mov ecx,[nBytes]
  shr ecx,2 ' bytes to dwords   
  mov ebx,[lpStart]
  mov edx,[lpEnd]  
  ' !!! and edx,&HFFFFFFFE

  copy_mp3frame_get:
    mov eax,[esi]
    mov [edi],eax
    add edi,4
    add esi,4
    cmp edi,edx
    jge copy_mp3frame_reset
    dec ecx
    jnz copy_mp3frame_get
    jmp copy_mp3frame_end

  copy_mp3frame_reset:
    mov edi,ebx
    dec ecx
    jnz copy_mp3frame_get

copy_mp3frame_end:
  mov esi,[lplpPlay]
  mov [esi],edi 'lpPlay=new pos
  end asm
end sub

private _
sub _CopySliceMP3Frameasm32(_B lpStart   as any ptr , _
                            _B lplpPlay  as any ptr ptr, _
                            _B lpEnd     as any ptr , _
                            _B lpSamples as any ptr , _
                            _B v         as single  , _ 
                            _B nBytes    as integer  )
  dim as integer speed=v*(1 shl 16) ' single to fixed point 16.16
  asm
  mov edi,[lplpPlay] 
  mov edi,[edi]
  mov esi,[lpSamples]
  mov ecx,[nBytes] 
  shr ecx,2       ' bytes to dwords
  xor ebx,ebx     ' temp var value

  CopySliceStream32_get:
    mov eax,[esi]  ' get 2*16bit samples

  CopySliceStream32_set:
    mov [edi],eax  ' put in destination buffer
    add  edi,4
    cmp edi,dword ptr [lpEnd]
    jge CopySliceStream32_reset

  CopySliceStream32_calc:
    dec ecx 
    jz  CopySliceStream32_end

    add ebx,dword ptr [speed] ' value+=step
    mov edx,ebx               ' save value
    and ebx,&HFFFF            ' value=value and 0000:FFFF
    shr edx,14                ' dwords
    and edx,&HFFFC
    jnz CopySliceStream32_add
    jmp CopySliceStream32_set

  CopySliceStream32_add:    
    add esi,edx    ' add only N*4 (dwords)
    jmp CopySliceStream32_get

  CopySliceStream32_reset:
    mov edi,[lpStart]
    jmp CopySliceStream32_calc

CopySliceStream32_end:
  mov esi,[lplpPlay]
  mov [esi],edi
end asm
end sub

private _
sub _CopySliceMP3FrameAsm16(_B lpStart   as any ptr , _
                            _B lplpPlay  as any ptr ptr, _
                            _B lpEnd     as any ptr , _
                            _B lpSamples as any ptr , _
                            _B v         as single  , _ 
                            _B nBytes    as integer  )
  dim as integer speed=v*(1 shl 16) ' single to fixed point 16.16
  asm
  mov edi,[lplpPlay] 
  mov edi,[edi]
  mov esi,[lpSamples]
  mov ecx,[nBytes] 
  shr ecx,1       ' bytes to words
  xor ebx,ebx     ' temp var value

  CopySliceMP3Frame16_get:
    mov ax,[esi]  ' get 16bit samples

  CopySliceMP3Frame16_set:
    mov [edi],ax  ' put in destination buffer
    add  edi,2
    cmp edi,dword ptr [lpEnd]
    jge CopySliceMP3Frame16_reset

  CopySliceMP3Frame16_calc:
    dec ecx 
    jz  CopySliceMP3Frame16_end

    add ebx,dword ptr [speed] ' value+=step
    mov edx,ebx               ' save value
    and ebx,&HFFFF            ' value=value and 0000:FFFF
    shr edx,15     ' words
    and edx,&HFFFE
    jnz CopySliceMP3Frame16_add
    jmp CopySliceMP3Frame16_set

  CopySliceMP3Frame16_add:    
    add esi,edx    ' add only N*4 (dwords)
    jmp CopySliceMP3Frame16_get

  CopySliceMP3Frame16_reset:
    mov edi,[lpStart]
    jmp CopySliceMP3Frame16_calc

CopySliceMP3Frame16_end:
  mov esi,[lplpPlay]
  mov [esi],edi '*lpPlay=edi
  end asm
end sub

#define MAD_F_ONE  &H10000000
#define MAD_F_MIN -MAD_F_ONE
#define MAD_F_MAX  MAD_F_ONE - 1
 'cmp eax,MAD_F_MAX
' fixed point 32 stereo to stereo 16
private  _
sub _ScaleMP3Frame_22_asm16(_B d  as any ptr , _
                            _B s1 as any ptr , _
                            _B s2 as any ptr , _
                            _B n  as integer  )
  asm
  mov edi,[d]
  mov esi,[s1]
  mov ebx,[s2]
  mov ecx,[n]

  ScaleMP3Frame_22_16_get_left:
    mov eax,[esi] ' left channel
    cmp eax,MAD_F_MAX
    jng ScaleMP3Frame_22_16_test_lmin
    mov word ptr [edi],&H7FFF
    jmp ScaleMP3Frame_22_16_get_right
  ScaleMP3Frame_22_16_test_lmin:
    cmp eax,MAD_F_MIN
    jnl ScaleMP3Frame_22_16_shift_left
    mov word ptr [edi],&H8000
    jmp ScaleMP3Frame_22_16_get_right
    ScaleMP3Frame_22_16_shift_left:
    shr eax,13
    mov [edi],ax

  ScaleMP3Frame_22_16_get_right:
    add edi,2
    mov eax,[ebx] ' right channel
    cmp eax,MAD_F_MAX
    jng ScaleMP3Frame_22_16_test_rmin  
    mov word ptr [edi],&H7FFF
    jmp ScaleMP3Frame_22_16_get_next
  ScaleMP3Frame_22_16_test_rmin:  
    cmp eax,MAD_F_MIN
    jnl ScaleMP3Frame_22_16_shift_right  
    mov word ptr [edi],&H8000
    jmp ScaleMP3Frame_22_16_get_next
    ScaleMP3Frame_22_16_shift_right:
    shr eax,13
    mov [edi],ax

  ScaleMP3Frame_22_16_get_next:
    add edi,2
    add esi,4
    add ebx,4
    dec ecx
  jnz ScaleMP3Frame_22_16_get_left
  end asm
end sub

' fixed point 32 stero to mono 16
private _
sub _ScaleMP3Frame_21_asm16(_B d  as any ptr , _
                            _B s1 as any ptr , _
                            _B s2 as any ptr , _
                            _B n  as integer)
  asm
  mov edi,[d]
  mov esi,[s1]
  mov ebx,[s2]
  mov ecx,[n]

  ScaleMP3Frame_21_16_get_L:
    mov edx,[esi] ' left channel
    cmp eax,MAD_F_MAX
    jng ScaleMP3Frame_21_16_test_left_min
    mov edx,&H7fff
    jmp ScaleMP3Frame_21_16_get_R

  ScaleMP3Frame_21_16_test_left_min:
    cmp eax,MAD_F_MIN
    jnl ScaleMP3Frame_21_16_shift_left
    mov edx,&H8000
    jmp ScaleMP3Frame_21_16_get_R

  ScaleMP3Frame_21_16_shift_left:
    shr edx,13

  ScaleMP3Frame_21_16_get_R:
    mov eax,[ebx] ' right channel
    cmp eax,MAD_F_MAX
    jng ScaleMP3Frame_21_16_test_right_min
    mov eax,&H7fff
    jmp ScaleMP3Frame_21_16_get_next

  ScaleMP3Frame_21_16_test_right_min:
    cmp eax,MAD_F_MIN
    jnl ScaleMP3Frame_21_16_shift_right
    mov eax,&H8000
    jmp ScaleMP3Frame_21_16_get_next

  ScaleMP3Frame_21_16_shift_right:
    shr eax,13

  ScaleMP3Frame_21_16_get_next:
    add eax,edx ' r+l
    shr eax,2   '(r+l)/2
    mov [edi],ax
    add edi,2
    add esi,4
    add ebx,4
    dec ecx
  jnz ScaleMP3Frame_21_16_get_L
  end asm
end sub

' fixed point 32 mono to stereo 16
private _
sub _ScaleMP3Frame_12_asm16(_B d  as any ptr , _
                            _B s1 as any ptr , _
                            _B n  as integer)
  asm
  mov edi,[d]
  mov esi,[s1]
  mov ecx,[n]
  mov ebx,&H80008000
  mov edx,&H7FFF7FFF

  ScaleMP3Frame_12_16_get:
    mov eax,[esi] ' mono channel
    cmp eax,MAD_F_MAX
    jng ScaleMP3Frame_12_16_test_min
    mov [edi],edx
    add edi,4
    add esi,4
    dec ecx
  jnz ScaleMP3Frame_12_16_get
  jmp ScaleMP3Frame_12_16_end

  ScaleMP3Frame_12_16_test_min:
    cmp eax,MAD_F_MIN
    jnl ScaleMP3Frame_12_16_shift
    mov [edi],ebx
    add edi,4
    add esi,4
    dec ecx
  jnz ScaleMP3Frame_12_16_get
  jmp ScaleMP3Frame_12_16_end

  ScaleMP3Frame_12_16_shift:
    shr eax,13
    mov [edi  ],ax
    mov [edi+2],ax
    add edi,4
    add esi,4
    dec ecx
  jnz ScaleMP3Frame_12_16_get
  ScaleMP3Frame_12_16_end:
  end asm
end sub

' fixed point 32 mono to mono 16
private _
sub _ScaleMP3Frame_11_asm16(_B d  as any ptr , _
                            _B s1 as any ptr , _
                            _B n  as integer)
  asm
  mov edi,[d]
  mov esi,[s1]
  mov ecx,[n]
  mov bx,&H8000
  mov dx,&H7Fff   
  ScaleMP3Frame_11_16_get:
    mov eax,[esi] ' mono channel
    cmp eax,MAD_F_MAX
    jng ScaleMP3Frame_11_16_test_min
    mov [edi],dx
    add edi,2
    add esi,4
    dec ecx
  jnz ScaleMP3Frame_11_16_get
  jmp ScaleMP3Frame_11_16_end

  ScaleMP3Frame_11_16_test_min:
    cmp eax,MAD_F_MIN
    jnl ScaleMP3Frame_11_16_shift
    mov [edi],bx
    add edi,2
    add esi,4
    dec ecx
  jnz ScaleMP3Frame_11_16_get
  jmp ScaleMP3Frame_11_16_end

  ScaleMP3Frame_11_16_shift:
    shr eax,13
    mov [edi],ax
    add edi,2
    add esi,4
    dec ecx
  jnz ScaleMP3Frame_11_16_get
  ScaleMP3Frame_11_16_end:
  end asm
end sub

' 16 bit to integer BASIC4GL buffer
private _
sub _ShortToIntegerasm(_B d  as any ptr , _
                       _B s  as any ptr , _
                       _B n  as integer)
  asm
  mov edi,[d]
  mov esi,[s]
  mov ecx,[n]
  shr ecx,2' bytes to short
  ShortToInteger_asm_loop:
    movsx eax,word ptr [esi]
    mov [edi],eax
    add esi,2
    add edi,4
    dec ecx
  jnz ShortToInteger_asm_loop
  end asm
end sub


'  ##################
' # init cpu layer #
'##################
dim shared ME as MMN_CPU

sub mmncpu_init() constructor
  dim as string   msg
  dim as integer  ct,r
  dim as longint c1,c2,cd
  dim as double t1,t2,td
  'dprint("cpu:()")

  if _IsCPUID()=true then
    r=_CPUIDEDX(1)
                               me.fpu =true:msg=      "FPU "
    if (r and &H10)       then me.tsc =true:msg=msg + "TSC "
    if (r and &H8000    ) then me.cmov=true:msg=msg + "CMOV "
    if (r and &H800000  ) then me.mmx =true:msg=msg + "MMX "
    if (r and &H2000000 ) then me.sse =true:msg=msg + "SSE "
    if (r and &H4000000 ) then me.sse2=true:msg=msg + "SSEII "

    r=_CPUIDEAX(&H80000000)
    if ((r and &H80000000)=&H80000000) and ((r and &HFF)>0) then 
      r=_CPUIDEDX(&H80000001)
      if (r and &H400000  ) then me.mmx2=true:msg=msg + "MMXII "
      if (r and &H80000000) then me.n3d =true:msg=msg + "3DNOW "
      if (r and &H40000000) then me.n3d2=true:msg=msg + "3DNOWII"
    end if
    'dprint(msg)
    'dprint("modules:init")
    if me.tsc=1 then
      me.cpucounter=@_TSC
      t1=timer()
      c1=me.cpucounter()
      while td<1.0:t2=timer:td=t2-t1:wend
      c2=me.cpucounter()
      cd=c2-c1
      cd\=1000000
      me.mhz=cint(cd*td)
      'dprint("MHz~"+str(me.mhz))
    end if

    if me.sse=true then 
      me.copy=@_copysse':dprint("copy(SSE)")
    elseif me.mmx=true then
      me.copy=@_copymmx':dprint("copy(MMX)")
    else
      me.copy=@_copyasm':dprint("copy(ASM)")
    end if

    if me.mmx=true then
      'dprint("mixer(MMX)")
      me.mix16=@_mixmmx16
    else
      'dprint("mixer(ASM)")
      me.mix16=@_mixasm16
    end if
    'dprint("zero, scale, shift, pan, dsp(ASM)")
    me.zero        =@_zeroasm   
    me.zerobuffer  =@_zerobuffer   
    me.scale16     =@_scaleasm16

    me.panleft16   =@_panleftasm16
    me.panright16  =@_panrightasm16

    me.copyright16 =@_copyrightasm16
    me.copyright32 =@_copyrightasm32
    me.moveright16 =@_moverightasm16
    me.moveright32 =@_moverightasm32

    me.copysliceright16 =@_copyslicerightasm16
    me.copysliceright32 =@_copyslicerightasm32
    me.movesliceright16 =@_moveslicerightasm16
    me.movesliceright32 =@_moveslicerightasm32

    me.copysliceleft16 =@_copysliceleftasm16
    me.copysliceleft32 =@_copysliceleftasm32
    me.movesliceleft16 =@_movesliceleftasm16
    me.movesliceleft32 =@_movesliceleftasm32

    me.CopyMP3Frame        =@_CopyMP3FrameASM
    me.CopySliceMP3Frame32 =@_CopySliceMP3FrameASM32
    me.CopySliceMP3Frame16 =@_CopySliceMP3FrameASM16
    me.ScaleMP3Frame_22_16 =@_ScaleMP3Frame_22_asm16
    me.ScaleMP3Frame_21_16 =@_ScaleMP3Frame_21_asm16
    me.ScaleMP3Frame_12_16 =@_ScaleMP3Frame_12_asm16
    me.ScaleMP3Frame_11_16 =@_ScaleMP3Frame_11_asm16

    me.ShortToInteger=@_ShortToIntegerasm
  else
    'dprint("FPU")
    ct=1000000/2.25*100
    t1=timer
    asm
    mov ecx,[ct]
    tloop:
    dec ecx
    cmp ecx,0
    jg tloop
    end asm
    t2=timer
    td=t2-t1
    me.mhz=int(100.0/td)
    'dprint("modules:init")
    'dprint("MHz~"+str(me.mhz))

    me.fpu=true
    me.cpucounter=@_cpucounter
    me.zero      =@_zeroasm
    me.zerobuffer=@_zerobuffer
    me.copy      =@_copyasm
    me.mix16     =@_mixasm16
    me.scale16   =@_scaleasm16

    me.panleft16 =@_panleftasm16
    me.panright16=@_panrightasm16

    me.copyright16 =@_copyrightasm16
    me.copyright32 =@_copyrightasm32
    me.moveright16 =@_moverightasm16
    me.moveright32 =@_moverightasm32
    me.copysliceright16 =@_copyslicerightasm16
    me.copysliceright32 =@_copyslicerightasm32
    me.movesliceright16 =@_moveslicerightasm16
    me.movesliceright32 =@_moveslicerightasm32

    me.copysliceleft16 =@_copysliceleftasm16
    me.copysliceleft32 =@_copysliceleftasm32
    me.movesliceleft16 =@_movesliceleftasm16
    me.movesliceleft32 =@_movesliceleftasm32

    me.CopyMP3Frame        =@_CopyMP3FrameASM
    me.CopySliceMP3Frame32 =@_CopySliceMP3FrameASM32
    me.CopySliceMP3Frame16 =@_CopySliceMP3FrameASM16
    me.ScaleMP3Frame_22_16 =@_ScaleMP3Frame_22_asm16
    me.ScaleMP3Frame_21_16 =@_ScaleMP3Frame_21_asm16
    me.ScaleMP3Frame_12_16 =@_ScaleMP3Frame_12_asm16
    me.ScaleMP3Frame_11_16 =@_ScaleMP3Frame_11_asm16

    me.ShortToInteger=@_ShortToIntegerasm
  end if
end sub

sub mmncpu_exit() destructor
  'dprint("cpu:~")
end sub

private function _cpucounter() as longint
  return me.mhz*timer()*1000000.0
end function 

function IsFPU()  as sndBoolean export
  return me.fpu
end function 
function IsTSC()  as sndBoolean export
  return me.tsc
end function 
function IsCMOV() as sndBoolean export
  return me.cmov
end function 
function IsMMX()  as sndBoolean export
  return me.mmx
end function 
function IsMMX2() as sndBoolean export
  return me.mmx
end function 
function IsSSE()  as sndBoolean export
  return me.sse
end function 
function IsSSE2() as sndBoolean export
  return me.sse2
end function 
function Is3DNOW() as sndBoolean export
  return me.n3d
end function 
function Is3DNOW2() as sndBoolean export
  return me.n3d2
end function 

function MHz() as integer EXPORT
  return me.mhz
end function 

function cpucounter() as longint EXPORT
  return me.cpucounter()
end function 

sub zero    (_B d as any ptr, _
             _B n as integer) EXPORT
  if (n>1) and (d<>0) then me.zero(d,n):exit sub
  dprint("cpu:zero wrong param!")
end sub

sub zerobuffer(_B s as any ptr , _
               _B p as any ptr ptr, _
               _B e as any ptr , _
               _B n as integer  ) EXPORT
  if (n>0) and (s<>0) then me.zerobuffer(s,p,e,n):exit sub
  dprint("cpu:zerobuffer wrong param!")
end sub

sub copy(_B d as any ptr, _
         _B s as any ptr, _
         _B n as integer ) EXPORT
  if (n>1) and (d<>0) and (s<>0) then me.copy(d,s,n):exit sub
  dprint("cpu:copy wrong param!")
end sub

sub mix16(_B d as any ptr, _
          _B a as any ptr, _
          _B b as any ptr, _
          _B n as integer ) EXPORT
  if (n>1) and (n and 1)=0 and (d<>0) and (a<>0) and (b<>0) then me.mix16(d,a,b,n):exit sub
  dprint("cpu:mix 16 wrong param!")
end sub

sub scale16(_B d as any ptr, _
            _B s as any ptr, _
            _B v as single , _
            _B n as integer ) EXPORT
  if n>1 and (n and 1)=0 and d<>0 and s<>0 then me.scale16(d,s,v,n):exit sub
  dprint("cpu:scale 16 wrong param!")
end sub 

sub pan16 (_B d as any ptr, _
           _B s as any ptr, _
           _B l as single , _
           _B r as single , _
           _B n as integer ) EXPORT
  if (n>0) and (n and 1)=0 and (l=1 or r=1) then 
    if l=1 then 
      me.panright16(d,s,r,n):exit sub
    else
      me.panleft16(d,s,l,n):exit sub  
    end if
  end if  
  dprint("cpu:pan 16 wrong param!")
end sub

sub copyright16(_B d as any ptr , _
                _B s as any ptr , _
                _B p as any ptr ptr, _
                _B e as any ptr , _
                _B l as any ptr ptr, _
                _B n as integer  ) export
 if n>0 then me.copyright16(d,s,p,e,l,n)
end sub

sub copyright32(_B d as any ptr , _
                _B s as any ptr , _
                _B p as any ptr ptr, _
                _B e as any ptr , _
                _B l as any ptr ptr, _
                _B n as integer  ) export
 if n>0 then me.copyright32(d,s,p,e,l,n)
end sub

sub moveright16(_B s as any ptr , _
                _B p as any ptr ptr, _
                _B e as any ptr , _
                _B l as any ptr ptr, _
                _B n as integer  ) export
 if (n>1) and (n and 1)=0 then me.moveright16(s,p,e,l,n):exit sub
 dprint("cpu: move right 16 wrong param!")
end sub

sub moveright32(_B s as any ptr , _
                _B p as any ptr ptr, _
                _B e as any ptr , _
                _B l as any ptr ptr, _
                _B n as integer) export
 if (n>1) and (n and 3)=0 then me.moveright32(s,p,e,l,n):exit sub
 dprint("cpu: move right 32 wrong param!" & str(n))
end sub

'copy slice right left
sub copysliceright16(_B d as any ptr , _
                     _B s as any ptr , _
                     _B p as any ptr ptr, _
                     _B e as any ptr , _
                     _B l as any ptr ptr, _
                     _B v as single  , _
                     _B n as integer  ) export
  if (n>1) and (n and 1)=0 and (v>0.0) then me.copysliceright16(d,s,p,e,l,v,n):exit sub
  dprint("cpu:copy slice right16 wrong param!")
end sub

sub copysliceright32(_B d as any ptr , _
                     _B s as any ptr , _
                     _B p as any ptr ptr, _
                     _B e as any ptr , _
                     _B l as any ptr ptr, _
                     _B v as single  , _
                     _B n as integer  ) export
  if (n>3) and (n and 3)=0 and (v>0.0) then me.copysliceright32(d,s,p,e,l,v,n):exit sub
  dprint("cpu:copy slice right32 wrong param!")
end sub

sub copysliceleft16(_B d as any ptr , _
                    _B s as any ptr , _
                    _B p as any ptr ptr, _
                    _B e as any ptr , _
                    _B l as any ptr ptr, _
                    _B v as single  , _
                    _B n as integer) export
  if (n>1) and (n and 1)=0 and (v<0.0) then me.copysliceleft16(d,s,p,e,l,v,n):exit sub
  dprint("cpu:copy slice left16 wrong param!")
end sub

sub copysliceleft32(_B d as any ptr , _
                    _B s as any ptr , _
                    _B p as any ptr ptr, _
                    _B e as any ptr , _
                    _B l as any ptr ptr, _
                    _B v as single  , _
                    _B n as integer) export
  if (n>3) and (n and 3)=0 and (v<0.0) then me.copysliceleft32(d,s,p,e,l,v,n):exit sub
  dprint("cpu:copy slice left32 wrong param!")
end sub

'move slice right left
sub movesliceright16(_B s as any ptr , _
                     _B p as any ptr ptr, _
                     _B e as any ptr , _
                     _B l as any ptr ptr, _
                     _B v as single  , _
                     _B n as integer) export
  if (n>1) and (n and 1)=0 and (v>0.0) then me.movesliceright16(s,p,e,l,v,n):exit sub
  dprint("cpu:move slice right16 wrong param!")
end sub

sub movesliceright32(_B s as any ptr , _
                     _B p as any ptr ptr, _
                     _B e as any ptr , _
                     _B l as any ptr ptr, _
                     _B v as single  , _
                     _B n as integer  ) export
  if (n>3) and (n and 3)=0 and (v>0.0) then me.movesliceright32(s,p,e,l,v,n):exit sub
  dprint("cpu:move slice right32 wrong param!")
end sub

sub movesliceleft16(_B s as any ptr , _
                    _B p as any ptr ptr, _
                    _B e as any ptr , _
                    _B l as any ptr ptr, _
                    _B v as single  , _
                    _B n as integer  ) export
  if (n>1) and (n and 1)=0 and (v<0.0) then me.movesliceleft16(s,p,e,l,v,n):exit sub
  dprint("cpu:move slice left16 wrong param!")
end sub

sub movesliceleft32(_B s as any ptr , _
                    _B p as any ptr ptr, _
                    _B e as any ptr , _
                    _B l as any ptr ptr, _
                    _B v as single  , _
                    _B n as integer  ) export
  if (n>3) and (n and 3)=0 and (v<0.0) then me.movesliceleft32(s,p,e,l,v,n):exit sub
  dprint("cpu:move slice left32 wrong param!")
end sub

sub CopyMP3Frame(_B s as any ptr , _
                 _B p as any ptr ptr, _
                 _B e as any ptr , _
                 _B f as any ptr , _ 
                 _B n as integer  ) export
  me.CopyMP3Frame(s,p,e,f,n)
end sub

sub CopySliceMP3Frame32(_B s as any ptr , _
                        _B p as any ptr ptr, _
                        _B e as any ptr , _
                        _B f as any ptr , _
                        _B v as single  , _ 
                        _B n as integer  ) export
  me.CopySliceMP3Frame32(s,p,e,f,v,n)
end sub

sub CopySliceMP3Frame16(_B s as any ptr , _
                        _B p as any ptr ptr, _
                        _B e as any ptr , _
                        _B f as any ptr , _
                        _B v as single  , _ 
                        _B n as integer  ) export
  me.CopySliceMP3Frame16(s,p,e,f,v,n)
end sub

sub ScaleMP3Frame_22_16(_B d  as any ptr , _
                        _B s1 as any ptr , _
                        _B s2 as any ptr , _
                        _B n  as integer  ) export
  me.ScaleMP3Frame_22_16(d,s1,s2,n)
end sub

sub ScaleMP3Frame_21_16(_B d  as any ptr , _
                        _B s1 as any ptr , _
                        _B s2 as any ptr , _
                        _B n  as integer  ) export
  me.ScaleMP3Frame_21_16(d,s1,s2,n)
end sub

sub ScaleMP3Frame_12_16(_B d  as any ptr , _
                        _B s1 as any ptr , _
                        _B n  as integer  ) export
  me.ScaleMP3Frame_12_16(d,s1,n)
end sub

sub ScaleMP3Frame_11_16(_B d  as any ptr , _
                        _B s1 as any ptr , _
                        _B n  as integer  ) export
  me.ScaleMP3Frame_11_16(d,s1,n)
end sub

sub ShortToInteger(_B d as any ptr , _
                   _B s as any ptr , _
                   _B n as integer) export
  me.ShortToInteger(d,s,n)
end sub
