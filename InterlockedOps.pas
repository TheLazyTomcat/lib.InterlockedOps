unit InterlockedOps;

{$IF defined(CPU64) or defined(CPU64BITS)}
  {$DEFINE CPU64bit}
{$ELSEIF defined(CPU16)}
  {$MESSAGE FATAL '16bit CPU not supported.'}
{$ELSE}
  {$DEFINE CPU32bit}
{$IFEND}

{$IF defined(CPUX86_64) or defined(CPUX64)}
  {$DEFINE x64}
{$ELSEIF defined(CPU386)}
  {$DEFINE x86}
{$ELSE}
  {$MESSAGE FATAL 'Unsupported CPU architecture.'}
{$IFEND}

{$IF Defined(WINDOWS) or Defined(MSWINDOWS)}
  {$DEFINE Windows}
{$IFEND}

{$IFDEF FPC}
  {$MODE ObjFPC}
  {$INLINE ON}
  {$DEFINE CanInline}
  {$IFNDEF PurePascal}
    {$ASMMODE Intel}
  {$ENDIF}
  {$DEFINE FPC_DisableWarns}
  {$MACRO ON}
{$ELSE}
  {$IF CompilerVersion >= 17 then}  // Delphi 2005+
    {$DEFINE CanInline}
  {$ELSE}
    {$UNDEF CanInline}
  {$IFEND}
{$ENDIF}
{$H+}

{$IFOPT Q+}
  {$DEFINE OverflowChecks}
{$ENDIF}

//------------------------------------------------------------------------------

{$DEFINE EnableVal64onSys32}

//------------------------------------------------------------------------------
// do not touch following define checks

{$IF Defined(CPU64bit) or Defined(EnableVal64onSys32)}
  {$DEFINE AllowVal64}
{$IFEND}

{$IFDEF PurePascal}
  {$MESSAGE WARN 'This unit cannot be compiled in PurePascal mode.'}
{$ENDIF}

interface

uses
  SysUtils,
  AuxTypes;

{
implementation bases
  ExchangeAdd
  CompareExchange

functions
  Inc
  Dec
  Add
  Sub
  Exchange
  ExchangeAdd
  ExchangeSub
  CompareExchange
  And
  Or
  Xor
  BitTestAndSet
  BitTestAndReset
  BitTestAndComplement


CmpExch in 128bit (64bit system only)
}
const
  IO_64BIT_VARS = {$IFDEF AllowVal64}True{$ELSE}False{$ENDIF};

type
  EIOException = class(Exception);

  EIOUnsupportedInstruction = class(EIOException);

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked increment
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedIncrement(var I: UInt8): UInt8; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedIncrement(var I: Int8): Int8; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedIncrement(var I: UInt16): UInt16; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedIncrement(var I: Int16): Int16; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedIncrement(var I: UInt32): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedIncrement(var I: Int32): Int32; overload;{$IFDEF CanInline} inline;{$ENDIF}

{$IFDEF AllowVal64}
Function InterlockedIncrement(var I: UInt64): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedIncrement(var I: Int64): Int64; overload;{$IFDEF CanInline} inline;{$ENDIF}
{$ENDIF}

Function InterlockedIncrement(var I: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked decrement
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedDecrement(var I: UInt8): UInt8; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedDecrement(var I: Int8): Int8; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedDecrement(var I: UInt16): UInt16; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedDecrement(var I: Int16): Int16; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedDecrement(var I: UInt32): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedDecrement(var I: Int32): Int32; overload;{$IFDEF CanInline} inline;{$ENDIF}

{$IFDEF AllowVal64}
Function InterlockedDecrement(var I: UInt64): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedDecrement(var I: Int64): Int64; overload;{$IFDEF CanInline} inline;{$ENDIF}
{$ENDIF}

Function InterlockedDecrement(var I: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                                Interlocked add
--------------------------------------------------------------------------------
===============================================================================}
(*
Function InterlockedAdd(var A: UInt8; B: UInt8): UInt8; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedAdd(var A: Int8; B: Int8): Int8; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedAdd(var A: UInt16; B: UInt16): UInt16; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedAdd(var A: Int16; B: Int16): Int16; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedAdd(var A: UInt32; B: UInt32): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedAdd(var A: Int32; B: Int32): Int32; overload;{$IFDEF CanInline} inline;{$ENDIF}

{$IFDEF AllowVal64}
Function InterlockedAdd(var A: UInt64; B: UInt64): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedAdd(var A: Int64; B: Int64): Int64; overload;{$IFDEF CanInline} inline;{$ENDIF}
{$ENDIF}

Function InterlockedAdd(var A: Pointer; B: PtrInt): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedAdd(var A: Pointer; B: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

*)
{===============================================================================
--------------------------------------------------------------------------------
                          Interlocked exchange and add
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeAdd(var A: UInt8; B: UInt8): UInt8; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedExchangeAdd(var A: Int8; B: Int8): Int8; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedExchangeAdd(var A: UInt16; B: UInt16): UInt16; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedExchangeAdd(var A: Int16; B: Int16): Int16; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedExchangeAdd(var A: UInt32; B: UInt32): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedExchangeAdd(var A: Int32; B: Int32): Int32; overload;{$IFDEF CanInline} inline;{$ENDIF}

{$IFDEF AllowVal64}
Function InterlockedExchangeAdd(var A: UInt64; B: UInt64): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedExchangeAdd(var A: Int64; B: Int64): Int64; overload;{$IFDEF CanInline} inline;{$ENDIF}
{$ENDIF}

Function InterlockedExchangeAdd(var A: Pointer; B: PtrInt): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedExchangeAdd(var A: Pointer; B: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                        Interlocked compare and exchange                         
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedCompareExchange(var Destination: UInt8; Exchange,Comparand: UInt8; out Exchanged: Boolean): UInt8; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedCompareExchange(var Destination: Int8; Exchange,Comparand: Int8; out Exchanged: Boolean): Int8; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedCompareExchange(var Destination: UInt16; Exchange,Comparand: UInt16; out Exchanged: Boolean): UInt16; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedCompareExchange(var Destination: Int16; Exchange,Comparand: Int16; out Exchanged: Boolean): Int16; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedCompareExchange(var Destination: UInt32; Exchange,Comparand: UInt32; out Exchanged: Boolean): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedCompareExchange(var Destination: Int32; Exchange,Comparand: Int32; out Exchanged: Boolean): Int32; overload;{$IFDEF CanInline} inline;{$ENDIF}

{$IFDEF AllowVal64}
Function InterlockedCompareExchange(var Destination: UInt64; Exchange,Comparand: UInt64; out Exchanged: Boolean): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedCompareExchange(var Destination: Int64; Exchange,Comparand: Int64; out Exchanged: Boolean): Int64; overload;{$IFDEF CanInline} inline;{$ENDIF}
{$ENDIF}

Function InterlockedCompareExchange(var Destination: Pointer; Exchange,Comparand: Pointer; out Exchanged: Boolean): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

//------------------------------------------------------------------------------

Function InterlockedCompareExchange(var Destination: UInt8; Exchange,Comparand: UInt8): UInt8; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedCompareExchange(var Destination: Int8; Exchange,Comparand: Int8): Int8; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedCompareExchange(var Destination: UInt16; Exchange,Comparand: UInt16): UInt16; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedCompareExchange(var Destination: Int16; Exchange,Comparand: Int16): Int16; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedCompareExchange(var Destination: UInt32; Exchange,Comparand: UInt32): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedCompareExchange(var Destination: Int32; Exchange,Comparand: Int32): Int32; overload;{$IFDEF CanInline} inline;{$ENDIF}

{$IFDEF AllowVal64}
Function InterlockedCompareExchange(var Destination: UInt64; Exchange,Comparand: UInt64): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedCompareExchange(var Destination: Int64; Exchange,Comparand: Int64): Int64; overload;{$IFDEF CanInline} inline;{$ENDIF}
{$ENDIF}

Function InterlockedCompareExchange(var Destination: Pointer; Exchange,Comparand: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

implementation

uses
  SimpleCPUID;

Function _InterlockedCompareExchange8(var Dest: UInt8; Exch,Comp: UInt8; out Exchanged: ByteBool): UInt8; register; assembler;
asm
{$IFDEF x64}
  {$IFDEF Windows}
          MOV     AL, R8B
    LOCK  CMPXCHG byte ptr [RCX], DL
  {$ELSE}
          MOV     AL, DL
    LOCK  CMPXCHG byte ptr [RDI], SIL
  {$ENDIF}
          // pointer to Exchanged is in a register (R9 on Windows, RCX elsewhere)
          SETZ    byte ptr [Exchanged]
{$ELSE}
          XCHG    EAX, ECX
    LOCK  CMPXCHG byte ptr [ECX], DL

          // pointer to Exchanged is on the stack
          MOV     EDX, dword ptr [Exchanged]
          SETZ    byte ptr [EDX]
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function _InterlockedCompareExchange16(var Dest: UInt16; Exch,Comp: UInt16; out Exchanged: ByteBool): UInt16; register; assembler;
asm
{$IFDEF x64}
  {$IFDEF Windows}
          MOV     AX, R8W
    LOCK  CMPXCHG word ptr [RCX], DX
  {$ELSE}
          MOV     AX, DX
    LOCK  CMPXCHG word ptr [RDI], SI
  {$ENDIF}
          SETZ    byte ptr [Exchanged]
{$ELSE}
          XCHG    EAX, ECX 
    LOCK  CMPXCHG word ptr [ECX], DX

          MOV     EDX, dword ptr [Exchanged]
          SETZ    byte ptr [EDX]
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function _InterlockedCompareExchange32(var Dest: UInt32; Exch,Comp: UInt32; out Exchanged: ByteBool): UInt32; register; assembler;
asm
{$IFDEF x64}
  {$IFDEF Windows}
          MOV     EAX, R8D
    LOCK  CMPXCHG dword ptr [RCX], EDX
  {$ELSE}
          MOV     EAX, EDX
    LOCK  CMPXCHG dword ptr [RDI], ESI
  {$ENDIF}
          SETZ    byte ptr [Exchanged]
{$ELSE}
          XCHG    EAX, ECX 
    LOCK  CMPXCHG dword ptr [ECX], EDX

          MOV     EDX, dword ptr [Exchanged]
          SETZ    byte ptr [EDX]
{$ENDIF}
end;

//------------------------------------------------------------------------------

{$IFDEF AllowVal64}
Function _InterlockedCompareExchange64(var Dest: UInt64; Exch: UInt64; Comp: UInt64; out Exchanged: ByteBool): UInt64; register; assembler;
asm
{$IFDEF x64}
  {$IFDEF Windows}
          MOV     RAX, R8
    LOCK  CMPXCHG qword ptr [RCX], RDX
  {$ELSE}
          MOV     RAX, RDX
    LOCK  CMPXCHG qword ptr [RDI], RSI
  {$ENDIF}
          SETZ    byte ptr [Exchanged]  
{$ELSE}
          PUSH  EBX
          PUSH  EDI
          PUSH  EDX   // save pointer to Exchanged

          // EAX will be rewritten, preserve pointer to Dest in EDI
          MOV   EDI, EAX

          // load Comp into registers
          MOV   EAX, dword ptr [Comp]
          MOV   EDX, dword ptr [Comp + 4]

          // load Exch into registers
          MOV   EBX, dword ptr [Exch]
          MOV   ECX, dword ptr [Exch + 4]

    LOCK  CMPXCHG8B qword ptr [EDI]

          POP   ECX   // load pointer to Exchanged
          SETZ  byte ptr [ECX]

          POP   EDI
          POP   EBX
{$ENDIF}
end;
{$ENDIF}

//==============================================================================

Function _InterlockedExchangeAdd8(var A: UInt8; B: UInt8): UInt8; register; assembler;
asm
{$IFDEF x64}
  {$IFDEF Windows}
    LOCK  XADD  byte ptr [RCX], DL
          MOV   AL, DL
  {$ELSE}
    LOCK  XADD  byte ptr [RDI], SIL
          MOV   AL, SIL
  {$ENDIF}
{$ELSE}
    LOCK  XADD  byte ptr [EAX], DL
          MOV   AL, DL
{$ENDIF}        
end;

//------------------------------------------------------------------------------

Function _InterlockedExchangeAdd16(var A: UInt16; B: UInt16): UInt16; register; assembler;
asm
{$IFDEF x64}
  {$IFDEF Windows}
    LOCK  XADD  word ptr [RCX], DX
          MOV   AX, DX
  {$ELSE}
    LOCK  XADD  word ptr [RDI], SI
          MOV   AX, SI
  {$ENDIF}
{$ELSE}
    LOCK  XADD  word ptr [EAX], DX
          MOV   AX, DX
{$ENDIF}        
end;

//------------------------------------------------------------------------------

Function _InterlockedExchangeAdd32(var A: UInt32; B: UInt32): UInt32; register; assembler;
asm
{$IFDEF x64}
  {$IFDEF Windows}
    LOCK  XADD  dword ptr [RCX], EDX
          MOV   EAX, EDX
  {$ELSE}
    LOCK  XADD  dword ptr [RDI], ESI
          MOV   EAX, ESI
  {$ENDIF}
{$ELSE}
    LOCK  XADD  dword ptr [EAX], EDX
          MOV   EAX, EDX
{$ENDIF}
end;

//------------------------------------------------------------------------------

{$IFDEF AllowVal64}
Function _InterlockedExchangeAdd64(var A: UInt64; B: UInt64): UInt64; {$IFDEF x64} register; assembler;
asm
  {$IFDEF Windows}
    LOCK  XADD  qword ptr [RCX], RDX
          MOV   RAX, RDX
  {$ELSE}
    LOCK  XADD  qword ptr [RDI], RSI
          MOV   RAX, RSI
  {$ENDIF}
end;
{$ELSE}
{$IFDEF OverflowChecks}{$Q-}{$ENDIF}
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _InterlockedCompareExchange64(A,B + Result,Result,Exchanged) = Result;
end;
{$IFDEF OverflowChecks}{$Q+}{$ENDIF}
{$ENDIF}
{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked increment                              
--------------------------------------------------------------------------------
===============================================================================}

{$IFDEF OverflowChecks}{$Q-}{$ENDIF}

Function InterlockedIncrement(var I: UInt8): UInt8;
begin
Result := _InterlockedExchangeAdd8(I,1) + 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int8): Int8;
begin
Result := Int8(_InterlockedExchangeAdd8(UInt8(I),1)) + 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: UInt16): UInt16;
begin
Result := _InterlockedExchangeAdd16(I,1) + 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int16): Int16;
begin
Result := Int16(_InterlockedExchangeAdd16(UInt16(I),1)) + 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: UInt32): UInt32;
begin
Result := _InterlockedExchangeAdd32(I,1) + 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int32): Int32;
begin
Result := Int32(_InterlockedExchangeAdd32(UInt32(I),1)) + 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedIncrement(var I: UInt64): UInt64;
begin
Result := _InterlockedExchangeAdd64(I,1) + 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int64): Int64;
begin
Result := Int64(_InterlockedExchangeAdd64(UInt64(I),1)) + 1;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_InterlockedExchangeAdd64(UInt64(I),1) + 1);
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_InterlockedExchangeAdd32(UInt32(I),1) + 1);
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{$IFDEF OverflowChecks}{$Q+}{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked decrement                              
--------------------------------------------------------------------------------
===============================================================================}

{$IFDEF OverflowChecks}{$Q-}{$ENDIF}

Function InterlockedDecrement(var I: UInt8): UInt8;
begin
Result := _InterlockedExchangeAdd8(I,UInt8(-1)) - 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int8): Int8;
begin
Result := Int8(_InterlockedExchangeAdd8(UInt8(I),UInt8(-1))) - 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: UInt16): UInt16;
begin
Result := _InterlockedExchangeAdd16(I,UInt16(-1)) - 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int16): Int16;
begin
Result := Int16(_InterlockedExchangeAdd16(UInt16(I),UInt16(-1))) - 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: UInt32): UInt32;
begin
Result := _InterlockedExchangeAdd32(I,UInt32(-1)) - 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int32): Int32;
begin
Result := Int32(_InterlockedExchangeAdd32(UInt32(I),UInt32(-1))) - 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedDecrement(var I: UInt64): UInt64;
begin
Result := _InterlockedExchangeAdd64(I,UInt64(-1)) - 1;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int64): Int64;
begin
Result := Int64(_InterlockedExchangeAdd64(UInt64(I),UInt64(-1))) - 1;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_InterlockedExchangeAdd64(UInt64(I),UInt64(-1)) - 1);
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_InterlockedExchangeAdd32(UInt32(I),UInt32(-1)) - 1);
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{$IFDEF OverflowChecks}{$Q+}{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                          Interlocked exchange and add
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeAdd(var A: UInt8; B: UInt8): UInt8;
begin
Result := _InterlockedExchangeAdd8(A,B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int8; B: Int8): Int8;
begin
Result := Int8(_InterlockedExchangeAdd8(UInt8(A),UInt8(B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: UInt16; B: UInt16): UInt16;
begin
Result := _InterlockedExchangeAdd16(A,B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int16; B: Int16): Int16;
begin
Result := Int16(_InterlockedExchangeAdd16(UInt16(A),UInt16(B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: UInt32; B: UInt32): UInt32;
begin
Result := _InterlockedExchangeAdd32(A,B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int32; B: Int32): Int32;
begin
Result := Int32(_InterlockedExchangeAdd32(UInt32(A),UInt32(B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedExchangeAdd(var A: UInt64; B: UInt64): UInt64;
begin
Result := _InterlockedExchangeAdd64(A,B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int64; B: Int64): Int64;
begin
Result := Int64(_InterlockedExchangeAdd64(UInt64(A),UInt64(B)));
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Pointer; B: PtrInt): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_InterlockedExchangeAdd64(UInt64(A),UInt64(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_InterlockedExchangeAdd32(UInt32(A),UInt32(B)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Pointer; B: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_InterlockedExchangeAdd64(UInt64(A),UInt64(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_InterlockedExchangeAdd32(UInt32(A),UInt32(B)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{===============================================================================
--------------------------------------------------------------------------------
                        Interlocked compare and exchange                         
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedCompareExchange(var Destination: UInt8; Exchange,Comparand: UInt8; out Exchanged: Boolean): UInt8;
var
  ExchangedBB:  ByteBool;
begin
Result := _InterlockedCompareExchange8(Destination,Exchange,Comparand,ExchangedBB);
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int8; Exchange,Comparand: Int8; out Exchanged: Boolean): Int8;
var
  ExchangedBB:  ByteBool;
begin
Result := Int8(_InterlockedCompareExchange8(UInt8(Destination),UInt8(Exchange),UInt8(Comparand),ExchangedBB));
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt16; Exchange,Comparand: UInt16; out Exchanged: Boolean): UInt16;
var
  ExchangedBB:  ByteBool;
begin
Result := _InterlockedCompareExchange16(Destination,Exchange,Comparand,ExchangedBB);
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int16; Exchange,Comparand: Int16; out Exchanged: Boolean): Int16;
var
  ExchangedBB:  ByteBool;
begin
Result := Int16(_InterlockedCompareExchange16(UInt16(Destination),UInt16(Exchange),UInt16(Comparand),ExchangedBB));
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt32; Exchange,Comparand: UInt32; out Exchanged: Boolean): UInt32;
var
  ExchangedBB:  ByteBool;
begin
Result := _InterlockedCompareExchange32(Destination,Exchange,Comparand,ExchangedBB);
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int32; Exchange,Comparand: Int32; out Exchanged: Boolean): Int32;
var
  ExchangedBB:  ByteBool;
begin
Result := Int32(_InterlockedCompareExchange32(UInt32(Destination),UInt32(Exchange),UInt32(Comparand),ExchangedBB));
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedCompareExchange(var Destination: UInt64; Exchange,Comparand: UInt64; out Exchanged: Boolean): UInt64;
var
  ExchangedBB:  ByteBool;
begin
Result := _InterlockedCompareExchange64(Destination,Exchange,Comparand,ExchangedBB);
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int64; Exchange,Comparand: Int64; out Exchanged: Boolean): Int64;
var
  ExchangedBB:  ByteBool;
begin
Result := Int64(_InterlockedCompareExchange64(UInt64(Destination),UInt64(Exchange),UInt64(Comparand),ExchangedBB));
Exchanged := ExchangedBB;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Pointer; Exchange,Comparand: Pointer; out Exchanged: Boolean): Pointer;
var
  ExchangedBB:  ByteBool;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_InterlockedCompareExchange64(UInt64(Destination),UInt64(Exchange),UInt64(Comparand),ExchangedBB));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_InterlockedCompareExchange32(UInt32(Destination),UInt32(Exchange),UInt32(Comparand),ExchangedBB));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
Exchanged := ExchangedBB;
end;

//------------------------------------------------------------------------------

Function InterlockedCompareExchange(var Destination: UInt8; Exchange,Comparand: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
Result := _InterlockedCompareExchange8(Destination,Exchange,Comparand,Exchanged);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int8; Exchange,Comparand: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
Result := Int8(_InterlockedCompareExchange8(UInt8(Destination),UInt8(Exchange),UInt8(Comparand),Exchanged));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt16; Exchange,Comparand: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
Result := _InterlockedCompareExchange16(Destination,Exchange,Comparand,Exchanged);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int16; Exchange,Comparand: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
Result := Int16(_InterlockedCompareExchange16(UInt16(Destination),UInt16(Exchange),UInt16(Comparand),Exchanged));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt32; Exchange,Comparand: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
Result := _InterlockedCompareExchange32(Destination,Exchange,Comparand,Exchanged);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int32; Exchange,Comparand: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
Result := Int32(_InterlockedCompareExchange32(UInt32(Destination),UInt32(Exchange),UInt32(Comparand),Exchanged));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedCompareExchange(var Destination: UInt64; Exchange,Comparand: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
Result := _InterlockedCompareExchange64(Destination,Exchange,Comparand,Exchanged);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int64; Exchange,Comparand: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
Result := Int64(_InterlockedCompareExchange64(UInt64(Destination),UInt64(Exchange),UInt64(Comparand),Exchanged));
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Pointer; Exchange,Comparand: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_InterlockedCompareExchange64(UInt64(Destination),UInt64(Exchange),UInt64(Comparand),Exchanged));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_InterlockedCompareExchange32(UInt32(Destination),UInt32(Exchange),UInt32(Comparand),Exchanged));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{===============================================================================
--------------------------------------------------------------------------------
                              Unit initialization
--------------------------------------------------------------------------------
===============================================================================}

procedure Initialize;
begin
with TSimpleCPUID.Create do
try
{$IF Defined(AllowVal64) and not Defined(x64)}
  If not Info.ProcessorFeatures.CX8 then          
    raise EIOUnsupportedInstruction.Create('Instruction CMPXCHG8B is not supported by current CPU.');
{$IFEND}    
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

initialization
  Initialize;

end.
