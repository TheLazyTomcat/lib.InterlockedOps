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
functions
    Inc
    Dec
    Add
    Sub
    Neg
    Not
    And
    Or
    Xor

    Exchange
    ExchangeAdd
    ExchangeSub
  ExchangeNeg
  ExchangeNot
  ExchangeAnd
  ExchangeOr
  ExchangeXor
    CompareExchange

  BitTest
  BitTestAndSet
  BitTestAndReset
  BitTestAndComplement

  Load
  Save

CmpExch in 128bit (64bit system only)
}
const
  ILO_64BIT_VARS = {$IFDEF AllowVal64}True{$ELSE}False{$ENDIF};

type
  EILOException = class(Exception);

  EILOUnsupportedInstruction = class(EILOException);

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
                              Interlocked addition
--------------------------------------------------------------------------------
===============================================================================}

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

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked subtraction
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedSub(var A: UInt8; B: UInt8): UInt8; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedSub(var A: Int8; B: Int8): Int8; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedSub(var A: UInt16; B: UInt16): UInt16; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedSub(var A: Int16; B: Int16): Int16; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedSub(var A: UInt32; B: UInt32): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedSub(var A: Int32; B: Int32): Int32; overload;{$IFDEF CanInline} inline;{$ENDIF}

{$IFDEF AllowVal64}
Function InterlockedSub(var A: UInt64; B: UInt64): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedSub(var A: Int64; B: Int64): Int64; overload;{$IFDEF CanInline} inline;{$ENDIF}
{$ENDIF}

Function InterlockedSub(var A: Pointer; B: PtrInt): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedSub(var A: Pointer; B: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked negation
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedNeg(var I: UInt8): UInt8; overload;
Function InterlockedNeg(var I: Int8): Int8; overload;

Function InterlockedNeg(var I: UInt16): UInt16; overload;
Function InterlockedNeg(var I: Int16): Int16; overload;

Function InterlockedNeg(var I: UInt32): UInt32; overload;
Function InterlockedNeg(var I: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedNeg(var I: UInt64): UInt64; overload;
Function InterlockedNeg(var I: Int64): Int64; overload;
{$ENDIF}

Function InterlockedNeg(var I: Pointer): Pointer; overload;

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked logical not
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedNot(var I: UInt8): UInt8; overload;
Function InterlockedNot(var I: Int8): Int8; overload;

Function InterlockedNot(var I: UInt16): UInt16; overload;
Function InterlockedNot(var I: Int16): Int16; overload;

Function InterlockedNot(var I: UInt32): UInt32; overload;
Function InterlockedNot(var I: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedNot(var I: UInt64): UInt64; overload;
Function InterlockedNot(var I: Int64): Int64; overload;
{$ENDIF}

Function InterlockedNot(var I: Pointer): Pointer; overload;

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked logical and
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedAnd(var A: UInt8; B: UInt8): UInt8; overload;
Function InterlockedAnd(var A: Int8; B: Int8): Int8; overload;

Function InterlockedAnd(var A: UInt16; B: UInt16): UInt16; overload;
Function InterlockedAnd(var A: Int16; B: Int16): Int16; overload;

Function InterlockedAnd(var A: UInt32; B: UInt32): UInt32; overload;
Function InterlockedAnd(var A: Int32; B: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedAnd(var A: UInt64; B: UInt64): UInt64; overload;
Function InterlockedAnd(var A: Int64; B: Int64): Int64; overload;
{$ENDIF}

Function InterlockedAnd(var A: Pointer; B: Pointer): Pointer; overload;

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked logical or
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedOr(var A: UInt8; B: UInt8): UInt8; overload;
Function InterlockedOr(var A: Int8; B: Int8): Int8; overload;

Function InterlockedOr(var A: UInt16; B: UInt16): UInt16; overload;
Function InterlockedOr(var A: Int16; B: Int16): Int16; overload;

Function InterlockedOr(var A: UInt32; B: UInt32): UInt32; overload;
Function InterlockedOr(var A: Int32; B: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedOr(var A: UInt64; B: UInt64): UInt64; overload;
Function InterlockedOr(var A: Int64; B: Int64): Int64; overload;
{$ENDIF}

Function InterlockedOr(var A: Pointer; B: Pointer): Pointer; overload;

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked logical xor
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedXor(var A: UInt8; B: UInt8): UInt8; overload;
Function InterlockedXor(var A: Int8; B: Int8): Int8; overload;

Function InterlockedXor(var A: UInt16; B: UInt16): UInt16; overload;
Function InterlockedXor(var A: Int16; B: Int16): Int16; overload;

Function InterlockedXor(var A: UInt32; B: UInt32): UInt32; overload;
Function InterlockedXor(var A: Int32; B: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedXor(var A: UInt64; B: UInt64): UInt64; overload;
Function InterlockedXor(var A: Int64; B: Int64): Int64; overload;
{$ENDIF}

Function InterlockedXor(var A: Pointer; B: Pointer): Pointer; overload;

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked exchange
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchange(var A: UInt8; B: UInt8): UInt8; overload;
Function InterlockedExchange(var A: Int8; B: Int8): Int8; overload;

Function InterlockedExchange(var A: UInt16; B: UInt16): UInt16; overload;
Function InterlockedExchange(var A: Int16; B: Int16): Int16; overload;

Function InterlockedExchange(var A: UInt32; B: UInt32): UInt32; overload;
Function InterlockedExchange(var A: Int32; B: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedExchange(var A: UInt64; B: UInt64): UInt64; overload;
Function InterlockedExchange(var A: Int64; B: Int64): Int64; overload;
{$ENDIF}

Function InterlockedExchange(var A: Pointer; B: Pointer): Pointer; overload;

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
                       Interlocked exchange and subtract
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeSub(var A: UInt8; B: UInt8): UInt8; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedExchangeSub(var A: Int8; B: Int8): Int8; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedExchangeSub(var A: UInt16; B: UInt16): UInt16; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedExchangeSub(var A: Int16; B: Int16): Int16; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedExchangeSub(var A: UInt32; B: UInt32): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedExchangeSub(var A: Int32; B: Int32): Int32; overload;{$IFDEF CanInline} inline;{$ENDIF}

{$IFDEF AllowVal64}
Function InterlockedExchangeSub(var A: UInt64; B: UInt64): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedExchangeSub(var A: Int64; B: Int64): Int64; overload;{$IFDEF CanInline} inline;{$ENDIF}
{$ENDIF}

Function InterlockedExchangeSub(var A: Pointer; B: PtrInt): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedExchangeSub(var A: Pointer; B: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

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

Function _iCMPXCHG8(var Dest: UInt8; Exch,Comp: UInt8; out Exchanged: ByteBool): UInt8; register; assembler;
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

Function _iCMPXCHG16(var Dest: UInt16; Exch,Comp: UInt16; out Exchanged: ByteBool): UInt16; register; assembler;
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

Function _iCMPXCHG32(var Dest: UInt32; Exch,Comp: UInt32; out Exchanged: ByteBool): UInt32; register; assembler;
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
Function _iCMPXCHG64(var Dest: UInt64; Exch: UInt64; Comp: UInt64; out Exchanged: ByteBool): UInt64; register; assembler;
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

Function _iXADD8(var A: UInt8; B: UInt8): UInt8; register; assembler;
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

Function _iXADD16(var A: UInt16; B: UInt16): UInt16; register; assembler;
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

Function _iXADD32(var A: UInt32; B: UInt32): UInt32; register; assembler;
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
Function _iXADD64(var A: UInt64; B: UInt64): UInt64; {$IFDEF x64} register; assembler;
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
until _iCMPXCHG64(A,B + Result,Result,Exchanged) = Result;
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
Result := UInt8(_iXADD8(I,1) + 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int8): Int8;
begin
Result := Int8(Int8(_iXADD8(UInt8(I),1)) + 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: UInt16): UInt16;
begin
Result := UInt16(_iXADD16(I,1) + 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int16): Int16;
begin
Result := Int16(Int16(_iXADD16(UInt16(I),1)) + 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: UInt32): UInt32;
begin
Result := UInt32(_iXADD32(I,1) + 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int32): Int32;
begin
Result := Int32(Int32(_iXADD32(UInt32(I),1)) + 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedIncrement(var I: UInt64): UInt64;
begin
Result := UInt64(_iXADD64(I,1) + 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int64): Int64;
begin
Result := Int64(Int64(_iXADD64(UInt64(I),1)) + 1);
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(I),1) + 1);
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(I),1) + 1);
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
Result := UInt8(_iXADD8(I,UInt8(-1)) - 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int8): Int8;
begin
Result := Int8(Int8(_iXADD8(UInt8(I),UInt8(-1))) - 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: UInt16): UInt16;
begin
Result := UInt16(_iXADD16(I,UInt16(-1)) - 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int16): Int16;
begin
Result := Int16(Int16(_iXADD16(UInt16(I),UInt16(-1))) - 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: UInt32): UInt32;
begin
Result := UInt32(_iXADD32(I,UInt32(-1)) - 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int32): Int32;
begin
Result := Int32(Int32(_iXADD32(UInt32(I),UInt32(-1))) - 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedDecrement(var I: UInt64): UInt64;
begin
Result := UInt64(_iXADD64(I,UInt64(-1)) - 1);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int64): Int64;
begin
Result := Int64(Int64(_iXADD64(UInt64(I),UInt64(-1))) - 1);
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(I),UInt64(-1)) - 1);
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(I),UInt32(-1)) - 1);
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{$IFDEF OverflowChecks}{$Q+}{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked addition
--------------------------------------------------------------------------------
===============================================================================}

{$IFDEF OverflowChecks}{$Q-}{$ENDIF}

Function InterlockedAdd(var A: UInt8; B: UInt8): UInt8;
begin
Result := UInt8(_iXADD8(A,B) + B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Int8; B: Int8): Int8;
begin
Result := Int8(Int8(_iXADD8(UInt8(A),UInt8(B))) + B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: UInt16; B: UInt16): UInt16;
begin
Result := UInt16(_iXADD16(A,B) + B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Int16; B: Int16): Int16;
begin
Result := Int16(Int16(_iXADD16(UInt16(A),UInt16(B))) + B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: UInt32; B: UInt32): UInt32;
begin
Result := UInt32(_iXADD32(A,B) + B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Int32; B: Int32): Int32;
begin
Result := Int32(Int32(_iXADD32(UInt32(A),UInt32(B))) + B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedAdd(var A: UInt64; B: UInt64): UInt64;
begin
Result := UInt64(_iXADD64(A,B) + B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Int64; B: Int64): Int64;
begin
Result := Int64(Int64(_iXADD64(UInt64(A),UInt64(B))) + B);
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Pointer; B: PtrInt): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(A),UInt64(B)) + UInt64(B));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(A),UInt32(B)) + UInt64(B));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Pointer; B: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(A),UInt64(B)) + UInt64(B));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(A),UInt32(B)) + UInt64(B));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{$IFDEF OverflowChecks}{$Q+}{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked subtraction
--------------------------------------------------------------------------------
===============================================================================}

{$IFDEF OverflowChecks}{$Q-}{$ENDIF}

Function InterlockedSub(var A: UInt8; B: UInt8): UInt8;
begin
Result := UInt8(_iXADD8(A,UInt8(-Int8(B))) - B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Int8; B: Int8): Int8;
begin
Result := Int8(Int8(_iXADD8(UInt8(A),UInt8(-B))) - B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: UInt16; B: UInt16): UInt16;
begin
Result := UInt16(_iXADD16(A,UInt16(-Int16(B))) - B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Int16; B: Int16): Int16;
begin
Result := Int16(Int16(_iXADD16(UInt16(A),UInt16(-B))) - B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: UInt32; B: UInt32): UInt32;
begin
Result := UInt32(_iXADD32(A,UInt32(-Int32(B))) - B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Int32; B: Int32): Int32;
begin
Result := Int32(Int32(_iXADD32(UInt32(A),UInt32(-B))) - B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedSub(var A: UInt64; B: UInt64): UInt64;
begin
Result := UInt64(_iXADD64(A,UInt64(-Int64(B))) - B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Int64; B: Int64): Int64;
begin
Result := Int64(Int64(_iXADD64(UInt64(A),UInt64(-B))) - B);
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Pointer; B: PtrInt): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(A),UInt64(-B)) - UInt64(B));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(A),UInt32(-B)) - UInt32(B));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Pointer; B: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(A),UInt64(-Int64(B))) - UInt64(B));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(A),UInt32(-Int32(B))) - UInt32(B));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{$IFDEF OverflowChecks}{$Q+}{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked negation
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedNeg(var I: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG8(I,UInt8(-Int8(Result)),Result,Exchanged) = Result;
Result := UInt8(-Int8(Result));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int8(_iCMPXCHG8(UInt8(I),UInt8(-Result),UInt8(Result),Exchanged)) = Result;
Result := -Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG16(I,UInt16(-Int16(Result)),Result,Exchanged) = Result;
Result := UInt16(-Int16(Result));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int16(_iCMPXCHG16(UInt16(I),UInt16(-Result),UInt16(Result),Exchanged)) = Result;
Result := -Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG32(I,UInt32(-Int32(Result)),Result,Exchanged) = Result;
Result := UInt32(-Int32(Result));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int32(_iCMPXCHG32(UInt32(I),UInt32(-Result),UInt32(Result),Exchanged)) = Result;
Result := -Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedNeg(var I: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG64(I,UInt64(-Int64(Result)),Result,Exchanged) = Result;
Result := UInt64(-Int64(Result));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int64(_iCMPXCHG64(UInt64(I),UInt64(-Result),UInt64(Result),Exchanged)) = Result;
Result := -Result;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(I),UInt64(-Int64(Result)),UInt64(Result),Exchanged)) = Result;
Result := Pointer(-Int64(Result));
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(I),UInt32(-Int32(Result)),UInt32(Result),Exchanged)) = Result;
Result := Pointer(-Int32(Result));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked logical not
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedNot(var I: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG8(I,not Result,Result,Exchanged) = Result;
Result := not Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int8(_iCMPXCHG8(UInt8(I),UInt8(not Result),UInt8(Result),Exchanged)) = Result;
Result := not Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG16(I,not Result,Result,Exchanged) = Result;
Result := not Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int16(_iCMPXCHG16(UInt16(I),UInt16(not Result),UInt16(Result),Exchanged)) = Result;
Result := not Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG32(I,not Result,Result,Exchanged) = Result;
Result := not Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int32(_iCMPXCHG32(UInt32(I),UInt32(not Result),UInt32(Result),Exchanged)) = Result;
Result := not Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedNot(var I: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG64(I,not Result,Result,Exchanged) = Result;
Result := not Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int64(_iCMPXCHG64(UInt64(I),UInt64(not Result),UInt64(Result),Exchanged)) = Result;
Result := not Result;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(I),not UInt64(Result),UInt64(Result),Exchanged)) = Result;
Result := Pointer(not UInt64(Result));
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(I),not UInt32(Result),UInt32(Result),Exchanged)) = Result;
Result := Pointer(not UInt32(Result));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked logical and
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedAnd(var A: UInt8; B: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG8(A,Result and B,Result,Exchanged) = Result;
Result := Result and B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: Int8; B: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int8(_iCMPXCHG8(UInt8(A),UInt8(Result and B),UInt8(Result),Exchanged)) = Result;
Result := Result and B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: UInt16; B: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG16(A,Result and B,Result,Exchanged) = Result;
Result := Result and B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: Int16; B: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int16(_iCMPXCHG16(UInt16(A),UInt16(Result and B),UInt16(Result),Exchanged)) = Result;
Result := Result and B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: UInt32; B: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG32(A,Result and B,Result,Exchanged) = Result;
Result := Result and B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: Int32; B: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int32(_iCMPXCHG32(UInt32(A),UInt32(Result and B),UInt32(Result),Exchanged)) = Result;
Result := Result and B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedAnd(var A: UInt64; B: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG64(A,Result and B,Result,Exchanged) = Result;
Result := Result and B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: Int64; B: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int64(_iCMPXCHG64(UInt64(A),UInt64(Result and B),UInt64(Result),Exchanged)) = Result;
Result := Result and B;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: Pointer; B: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(A),UInt64(Result) and UInt64(B),UInt64(Result),Exchanged)) = Result;
Result := Pointer(UInt64(Result) and UInt64(B));
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(A),UInt32(Result) and UInt32(B),UInt32(Result),Exchanged)) = Result;
Result := Pointer(UInt32(Result) and UInt32(B));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked logical or
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedOr(var A: UInt8; B: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG8(A,Result or B,Result,Exchanged) = Result;
Result := Result or B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: Int8; B: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int8(_iCMPXCHG8(UInt8(A),UInt8(Result or B),UInt8(Result),Exchanged)) = Result;
Result := Result or B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: UInt16; B: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG16(A,Result or B,Result,Exchanged) = Result;
Result := Result or B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: Int16; B: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int16(_iCMPXCHG16(UInt16(A),UInt16(Result or B),UInt16(Result),Exchanged)) = Result;
Result := Result or B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: UInt32; B: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG32(A,Result or B,Result,Exchanged) = Result;
Result := Result or B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: Int32; B: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int32(_iCMPXCHG32(UInt32(A),UInt32(Result or B),UInt32(Result),Exchanged)) = Result;
Result := Result or B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedOr(var A: UInt64; B: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG64(A,Result or B,Result,Exchanged) = Result;
Result := Result or B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: Int64; B: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int64(_iCMPXCHG64(UInt64(A),UInt64(Result or B),UInt64(Result),Exchanged)) = Result;
Result := Result or B;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: Pointer; B: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(A),UInt64(Result) or UInt64(B),UInt64(Result),Exchanged)) = Result;
Result := Pointer(UInt64(Result) or UInt64(B));
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(A),UInt32(Result) or UInt32(B),UInt32(Result),Exchanged)) = Result;
Result := Pointer(UInt32(Result) or UInt32(B));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked logical xor
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedXor(var A: UInt8; B: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG8(A,Result xor B,Result,Exchanged) = Result;
Result := Result xor B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: Int8; B: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int8(_iCMPXCHG8(UInt8(A),UInt8(Result xor B),UInt8(Result),Exchanged)) = Result;
Result := Result xor B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: UInt16; B: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG16(A,Result xor B,Result,Exchanged) = Result;
Result := Result xor B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: Int16; B: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int16(_iCMPXCHG16(UInt16(A),UInt16(Result xor B),UInt16(Result),Exchanged)) = Result;
Result := Result xor B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: UInt32; B: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG32(A,Result xor B,Result,Exchanged) = Result;
Result := Result xor B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: Int32; B: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int32(_iCMPXCHG32(UInt32(A),UInt32(Result xor B),UInt32(Result),Exchanged)) = Result;
Result := Result xor B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedXor(var A: UInt64; B: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG64(A,Result xor B,Result,Exchanged) = Result;
Result := Result xor B;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: Int64; B: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int64(_iCMPXCHG64(UInt64(A),UInt64(Result xor B),UInt64(Result),Exchanged)) = Result;
Result := Result xor B;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: Pointer; B: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(A),UInt64(Result) xor UInt64(B),UInt64(Result),Exchanged)) = Result;
Result := Pointer(UInt64(Result) xor UInt64(B));
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(A),UInt32(Result) xor UInt32(B),UInt32(Result),Exchanged)) = Result;
Result := Pointer(UInt32(Result) xor UInt32(B));
{$ELSE}
  {$MESSAGE FATAL 'Unsuppxorted size of pointer.'}
{$IFEND}
end;

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked exchange
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchange(var A: UInt8; B: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG8(A,B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: Int8; B: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG8(UInt8(A),UInt8(B),UInt8(Result),Exchanged) = UInt8(Result);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: UInt16; B: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG16(A,B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: Int16; B: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG16(UInt16(A),UInt16(B),UInt16(Result),Exchanged) = UInt16(Result);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: UInt32; B: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG32(A,B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: Int32; B: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG32(UInt32(A),UInt32(B),UInt32(Result),Exchanged) = UInt32(Result);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedExchange(var A: UInt64; B: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG64(A,B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: Int64; B: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG64(UInt64(A),UInt64(B),UInt64(Result),Exchanged) = UInt64(Result);
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: Pointer; B: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
{$IF SizeOf(Pointer) = 8}
until _iCMPXCHG64(UInt64(A),UInt64(B),UInt64(Result),Exchanged) = UInt64(Result);
{$ELSEIF SizeOf(Pointer) = 4}
until _iCMPXCHG32(UInt32(A),UInt32(B),UInt32(Result),Exchanged) = UInt32(Result);
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{===============================================================================
--------------------------------------------------------------------------------
                          Interlocked exchange and add
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeAdd(var A: UInt8; B: UInt8): UInt8;
begin
Result := _iXADD8(A,B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int8; B: Int8): Int8;
begin
Result := Int8(_iXADD8(UInt8(A),UInt8(B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: UInt16; B: UInt16): UInt16;
begin
Result := _iXADD16(A,B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int16; B: Int16): Int16;
begin
Result := Int16(_iXADD16(UInt16(A),UInt16(B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: UInt32; B: UInt32): UInt32;
begin
Result := _iXADD32(A,B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int32; B: Int32): Int32;
begin
Result := Int32(_iXADD32(UInt32(A),UInt32(B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedExchangeAdd(var A: UInt64; B: UInt64): UInt64;
begin
Result := _iXADD64(A,B);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int64; B: Int64): Int64;
begin
Result := Int64(_iXADD64(UInt64(A),UInt64(B)));
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Pointer; B: PtrInt): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(A),UInt64(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(A),UInt32(B)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Pointer; B: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(A),UInt64(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(A),UInt32(B)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{===============================================================================
--------------------------------------------------------------------------------
                       Interlocked exchange and subtract
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeSub(var A: UInt8; B: UInt8): UInt8;
begin
Result := _iXADD8(A,UInt8(-Int8(B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Int8; B: Int8): Int8;
begin
Result := Int8(_iXADD8(UInt8(A),UInt8(-B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: UInt16; B: UInt16): UInt16;
begin
Result := _iXADD16(A,UInt16(-Int16(B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Int16; B: Int16): Int16;
begin
Result := Int16(_iXADD16(UInt16(A),UInt16(-B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: UInt32; B: UInt32): UInt32;
begin
Result := _iXADD32(A,UInt32(-Int32(B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Int32; B: Int32): Int32;
begin
Result := Int32(_iXADD32(UInt32(A),UInt32(-B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedExchangeSub(var A: UInt64; B: UInt64): UInt64;
begin
Result := _iXADD64(A,UInt64(-Int64(B)));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Int64; B: Int64): Int64;
begin
Result := Int64(_iXADD64(UInt64(A),UInt64(-B)));
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Pointer; B: PtrInt): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(A),UInt64(-Int64(B))));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(A),UInt32(-Int32(B))));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Pointer; B: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(A),UInt64(-Int64(B))));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(A),UInt32(-Int32(B))));
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
Result := _iCMPXCHG8(Destination,Exchange,Comparand,ExchangedBB);
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int8; Exchange,Comparand: Int8; out Exchanged: Boolean): Int8;
var
  ExchangedBB:  ByteBool;
begin
Result := Int8(_iCMPXCHG8(UInt8(Destination),UInt8(Exchange),UInt8(Comparand),ExchangedBB));
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt16; Exchange,Comparand: UInt16; out Exchanged: Boolean): UInt16;
var
  ExchangedBB:  ByteBool;
begin
Result := _iCMPXCHG16(Destination,Exchange,Comparand,ExchangedBB);
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int16; Exchange,Comparand: Int16; out Exchanged: Boolean): Int16;
var
  ExchangedBB:  ByteBool;
begin
Result := Int16(_iCMPXCHG16(UInt16(Destination),UInt16(Exchange),UInt16(Comparand),ExchangedBB));
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt32; Exchange,Comparand: UInt32; out Exchanged: Boolean): UInt32;
var
  ExchangedBB:  ByteBool;
begin
Result := _iCMPXCHG32(Destination,Exchange,Comparand,ExchangedBB);
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int32; Exchange,Comparand: Int32; out Exchanged: Boolean): Int32;
var
  ExchangedBB:  ByteBool;
begin
Result := Int32(_iCMPXCHG32(UInt32(Destination),UInt32(Exchange),UInt32(Comparand),ExchangedBB));
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedCompareExchange(var Destination: UInt64; Exchange,Comparand: UInt64; out Exchanged: Boolean): UInt64;
var
  ExchangedBB:  ByteBool;
begin
Result := _iCMPXCHG64(Destination,Exchange,Comparand,ExchangedBB);
Exchanged := ExchangedBB;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int64; Exchange,Comparand: Int64; out Exchanged: Boolean): Int64;
var
  ExchangedBB:  ByteBool;
begin
Result := Int64(_iCMPXCHG64(UInt64(Destination),UInt64(Exchange),UInt64(Comparand),ExchangedBB));
Exchanged := ExchangedBB;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Pointer; Exchange,Comparand: Pointer; out Exchanged: Boolean): Pointer;
var
  ExchangedBB:  ByteBool;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iCMPXCHG64(UInt64(Destination),UInt64(Exchange),UInt64(Comparand),ExchangedBB));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iCMPXCHG32(UInt32(Destination),UInt32(Exchange),UInt32(Comparand),ExchangedBB));
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
Result := _iCMPXCHG8(Destination,Exchange,Comparand,Exchanged);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int8; Exchange,Comparand: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
Result := Int8(_iCMPXCHG8(UInt8(Destination),UInt8(Exchange),UInt8(Comparand),Exchanged));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt16; Exchange,Comparand: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
Result := _iCMPXCHG16(Destination,Exchange,Comparand,Exchanged);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int16; Exchange,Comparand: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
Result := Int16(_iCMPXCHG16(UInt16(Destination),UInt16(Exchange),UInt16(Comparand),Exchanged));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt32; Exchange,Comparand: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
Result := _iCMPXCHG32(Destination,Exchange,Comparand,Exchanged);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int32; Exchange,Comparand: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
Result := Int32(_iCMPXCHG32(UInt32(Destination),UInt32(Exchange),UInt32(Comparand),Exchanged));
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedCompareExchange(var Destination: UInt64; Exchange,Comparand: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
Result := _iCMPXCHG64(Destination,Exchange,Comparand,Exchanged);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int64; Exchange,Comparand: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
Result := Int64(_iCMPXCHG64(UInt64(Destination),UInt64(Exchange),UInt64(Comparand),Exchanged));
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Pointer; Exchange,Comparand: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iCMPXCHG64(UInt64(Destination),UInt64(Exchange),UInt64(Comparand),Exchanged));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iCMPXCHG32(UInt32(Destination),UInt32(Exchange),UInt32(Comparand),Exchanged));
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
    raise EILOUnsupportedInstruction.Create('Instruction CMPXCHG8B is not supported by current CPU.');
{$IFEND}    
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

initialization
  Initialize;

end.
