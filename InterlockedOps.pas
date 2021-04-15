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
  {$ASMMODE Intel}
  {$INLINE ON}
  {$DEFINE CanInline}
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

{$DEFINE EnableVal128}

//------------------------------------------------------------------------------
// do not touch following define checks

{$IF Defined(CPU64bit) or Defined(EnableVal64onSys32)}
  {$DEFINE AllowVal64}
{$IFEND}

{$IF Defined(EnableVal128) and Defined(x64)}
  {$DEFINE AllowVal128}
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
    Store

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

Function InterlockedIncrement(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedIncrement(var I: Int8): Int8; overload; register; assembler;

Function InterlockedIncrement(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedIncrement(var I: Int16): Int16; overload; register; assembler;

Function InterlockedIncrement(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedIncrement(var I: Int32): Int32; overload; register; assembler;

{$IFDEF AllowVal64}
Function InterlockedIncrement(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedIncrement(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedIncrement(var I: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked decrement
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedDecrement(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedDecrement(var I: Int8): Int8; overload; register; assembler;

Function InterlockedDecrement(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedDecrement(var I: Int16): Int16; overload; register; assembler;

Function InterlockedDecrement(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedDecrement(var I: Int32): Int32; overload; register; assembler;

{$IFDEF AllowVal64}
Function InterlockedDecrement(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedDecrement(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedDecrement(var I: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked addition
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedAdd(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedAdd(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedAdd(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedAdd(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedAdd(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedAdd(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF AllowVal64}
Function InterlockedAdd(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedAdd(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedAdd(var A: Pointer; B: PtrInt): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedAdd(var A: Pointer; B: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked subtraction
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedSub(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedSub(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedSub(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedSub(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedSub(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedSub(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF AllowVal64}
Function InterlockedSub(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedSub(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedSub(var A: Pointer; B: PtrInt): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedSub(var A: Pointer; B: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked negation
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedNeg(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedNeg(var I: Int8): Int8; overload; register; assembler;

Function InterlockedNeg(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedNeg(var I: Int16): Int16; overload; register; assembler;

Function InterlockedNeg(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedNeg(var I: Int32): Int32; overload; register; assembler;

{$IFDEF AllowVal64}
Function InterlockedNeg(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedNeg(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedNeg(var I: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked logical not
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedNot(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedNot(var I: Int8): Int8; overload; register; assembler;

Function InterlockedNot(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedNot(var I: Int16): Int16; overload; register; assembler;

Function InterlockedNot(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedNot(var I: Int32): Int32; overload; register; assembler;

{$IFDEF AllowVal64}
Function InterlockedNot(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedNot(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedNot(var I: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked logical and
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedAnd(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedAnd(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedAnd(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedAnd(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedAnd(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedAnd(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF AllowVal64}
Function InterlockedAnd(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedAnd(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedAnd(var A: Pointer; B: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked logical or
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedOr(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedOr(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedOr(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedOr(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedOr(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedOr(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF AllowVal64}
Function InterlockedOr(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedOr(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedOr(var A: Pointer; B: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked logical xor
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedXor(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedXor(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedXor(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedXor(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedXor(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedXor(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF AllowVal64}
Function InterlockedXor(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedXor(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedXor(var A: Pointer; B: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

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
                       Interlocked exchange and negation
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeNeg(var I: UInt8): UInt8; overload;
Function InterlockedExchangeNeg(var I: Int8): Int8; overload;

Function InterlockedExchangeNeg(var I: UInt16): UInt16; overload;
Function InterlockedExchangeNeg(var I: Int16): Int16; overload;

Function InterlockedExchangeNeg(var I: UInt32): UInt32; overload;
Function InterlockedExchangeNeg(var I: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedExchangeNeg(var I: UInt64): UInt64; overload;
Function InterlockedExchangeNeg(var I: Int64): Int64; overload;
{$ENDIF}

Function InterlockedExchangeNeg(var I: Pointer): Pointer; overload;

{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical not
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeNot(var I: UInt8): UInt8; overload;
Function InterlockedExchangeNot(var I: Int8): Int8; overload;

Function InterlockedExchangeNot(var I: UInt16): UInt16; overload;
Function InterlockedExchangeNot(var I: Int16): Int16; overload;

Function InterlockedExchangeNot(var I: UInt32): UInt32; overload;
Function InterlockedExchangeNot(var I: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedExchangeNot(var I: UInt64): UInt64; overload;
Function InterlockedExchangeNot(var I: Int64): Int64; overload;
{$ENDIF}

Function InterlockedExchangeNot(var I: Pointer): Pointer; overload;

{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical and
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeAnd(var A: UInt8; B: UInt8): UInt8; overload;
Function InterlockedExchangeAnd(var A: Int8; B: Int8): Int8; overload;

Function InterlockedExchangeAnd(var A: UInt16; B: UInt16): UInt16; overload;
Function InterlockedExchangeAnd(var A: Int16; B: Int16): Int16; overload;

Function InterlockedExchangeAnd(var A: UInt32; B: UInt32): UInt32; overload;
Function InterlockedExchangeAnd(var A: Int32; B: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedExchangeAnd(var A: UInt64; B: UInt64): UInt64; overload;
Function InterlockedExchangeAnd(var A: Int64; B: Int64): Int64; overload;
{$ENDIF}

Function InterlockedExchangeAnd(var A: Pointer; B: Pointer): Pointer; overload;

{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical or
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeOr(var A: UInt8; B: UInt8): UInt8; overload;
Function InterlockedExchangeOr(var A: Int8; B: Int8): Int8; overload;

Function InterlockedExchangeOr(var A: UInt16; B: UInt16): UInt16; overload;
Function InterlockedExchangeOr(var A: Int16; B: Int16): Int16; overload;

Function InterlockedExchangeOr(var A: UInt32; B: UInt32): UInt32; overload;
Function InterlockedExchangeOr(var A: Int32; B: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedExchangeOr(var A: UInt64; B: UInt64): UInt64; overload;
Function InterlockedExchangeOr(var A: Int64; B: Int64): Int64; overload;
{$ENDIF}

Function InterlockedExchangeOr(var A: Pointer; B: Pointer): Pointer; overload;

{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical xor
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeXor(var A: UInt8; B: UInt8): UInt8; overload;
Function InterlockedExchangeXor(var A: Int8; B: Int8): Int8; overload;

Function InterlockedExchangeXor(var A: UInt16; B: UInt16): UInt16; overload;
Function InterlockedExchangeXor(var A: Int16; B: Int16): Int16; overload;

Function InterlockedExchangeXor(var A: UInt32; B: UInt32): UInt32; overload;
Function InterlockedExchangeXor(var A: Int32; B: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedExchangeXor(var A: UInt64; B: UInt64): UInt64; overload;
Function InterlockedExchangeXor(var A: Int64; B: Int64): Int64; overload;
{$ENDIF}

Function InterlockedExchangeXor(var A: Pointer; B: Pointer): Pointer; overload;

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

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked bit test
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedBitTest(var I: UInt8; Bit: Integer): Boolean; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                          Interlocked bit test and set
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedBitTestAndSet(var I: UInt8; Bit: Integer): Boolean; overload;

{===============================================================================
--------------------------------------------------------------------------------
                                Interlocked load
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedLoad(var I: UInt8): UInt8; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedLoad(var I: Int8): Int8; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedLoad(var I: UInt16): UInt16; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedLoad(var I: Int16): Int16; overload;{$IFDEF CanInline} inline;{$ENDIF}

Function InterlockedLoad(var I: UInt32): UInt32; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedLoad(var I: Int32): Int32; overload;{$IFDEF CanInline} inline;{$ENDIF}

{$IFDEF AllowVal64}
Function InterlockedLoad(var I: UInt64): UInt64; overload;{$IFDEF CanInline} inline;{$ENDIF}
Function InterlockedLoad(var I: Int64): Int64; overload;{$IFDEF CanInline} inline;{$ENDIF}
{$ENDIF}

Function InterlockedLoad(var I: Pointer): Pointer; overload;{$IFDEF CanInline} inline;{$ENDIF}

{===============================================================================
--------------------------------------------------------------------------------
                               Interlocked store                                                               
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedStore(var I: UInt8; NewValue: UInt8): UInt8; overload;
Function InterlockedStore(var I: Int8; NewValue: Int8): Int8; overload;

Function InterlockedStore(var I: UInt16; NewValue: UInt16): UInt16; overload;
Function InterlockedStore(var I: Int16; NewValue: Int16): Int16; overload;

Function InterlockedStore(var I: UInt32; NewValue: UInt32): UInt32; overload;
Function InterlockedStore(var I: Int32; NewValue: Int32): Int32; overload;

{$IFDEF AllowVal64}
Function InterlockedStore(var I: UInt64; NewValue: UInt64): UInt64; overload;
Function InterlockedStore(var I: Int64; NewValue: Int64): Int64; overload;
{$ENDIF}

Function InterlockedStore(var I: Pointer; NewValue: Pointer): Pointer; overload;

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
asm
          MOV   DL, 1
    LOCK  XADD  byte ptr [I], DL
          MOV   AL, DL
          INC   AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int8): Int8;
asm
          MOV   DL, 1
    LOCK  XADD  byte ptr [I], DL
          MOV   AL, DL
          INC   AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: UInt16): UInt16;
asm
          MOV   DX, 1
    LOCK  XADD  word ptr [I], DX
          MOV   AX, DX
          INC   AX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int16): Int16;
asm
          MOV   DX, 1
    LOCK  XADD  word ptr [I], DX
          MOV   AX, DX
          INC   AX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: UInt32): UInt32;
asm
          MOV   EDX, 1
    LOCK  XADD  dword ptr [I], EDX
          MOV   EAX, EDX
          INC   EAX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int32): Int32;
asm
          MOV   EDX, 1
    LOCK  XADD  dword ptr [I], EDX
          MOV   EAX, EDX
          INC   EAX
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedIncrement(var I: UInt64): UInt64;
asm
{$IFDEF x64}
          MOV   RDX, 1
    LOCK  XADD  qword ptr [I], RDX
          MOV   RAX, RDX
          INC   RAX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          ADD   EBX, 1
          ADC   ECX, 0

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Int64): Int64;
asm
{$IFDEF x64}
          MOV   RDX, 1
    LOCK  XADD  qword ptr [I], RDX
          MOV   RAX, RDX
          INC   RAX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          ADD   EBX, 1
          ADC   ECX, 0

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedIncrement(var I: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedIncrement(UInt64(I)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedIncrement(UInt32(I)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;


{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked decrement                              
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedDecrement(var I: UInt8): UInt8;
asm
          MOV   DL, byte(-1)
    LOCK  XADD  byte ptr [I], DL
          MOV   AL, DL
          DEC   AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int8): Int8;
asm
          MOV   DL, byte(-1)
    LOCK  XADD  byte ptr [I], DL
          MOV   AL, DL
          DEC   AL
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: UInt16): UInt16;
asm
          MOV   DX, word(-1)
    LOCK  XADD  word ptr [I], DX
          MOV   AX, DX
          DEC   AX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int16): Int16;
asm
          MOV   DX, word(-1)
    LOCK  XADD  word ptr [I], DX
          MOV   AX, DX
          DEC   AX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: UInt32): UInt32;
asm
          MOV   EDX, dword(-1)
    LOCK  XADD  dword ptr [I], EDX
          MOV   EAX, EDX
          DEC   EAX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int32): Int32;
asm
          MOV   EDX, dword(-1)
    LOCK  XADD  dword ptr [I], EDX
          MOV   EAX, EDX
          DEC   EAX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedDecrement(var I: UInt64): UInt64;
asm
{$IFDEF x64}
          MOV   RDX, qword(-1)
    LOCK  XADD  qword ptr [I], RDX
          MOV   RAX, RDX
          DEC   RAX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          SUB   EBX, 1
          SBB   ECX, 0

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Int64): Int64;
asm
{$IFDEF x64}
          MOV   RDX, qword(-1)
    LOCK  XADD  qword ptr [I], RDX
          MOV   RAX, RDX
          DEC   RAX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          SUB   EBX, 1
          SBB   ECX, 0

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedDecrement(var I: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedDecrement(UInt64(I)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedDecrement(UInt32(I)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;


{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked addition
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedAdd(var A: UInt8; B: UInt8): UInt8;
asm
{$IFDEF x64}
          MOV   AL, B
    LOCK  XADD  byte ptr [A], AL
          ADD   AL, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   CL, DL
    LOCK  XADD  byte ptr [EAX], DL
          MOV   AL, DL
          ADD   AL, CL
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Int8; B: Int8): Int8;
asm
{$IFDEF x64}
          MOV   AL, B
    LOCK  XADD  byte ptr [A], AL
          ADD   AL, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   CL, DL
    LOCK  XADD  byte ptr [EAX], DL
          MOV   AL, DL
          ADD   AL, CL
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: UInt16; B: UInt16): UInt16;
asm
{$IFDEF x64}
          MOV   AX, B
    LOCK  XADD  word ptr [A], AX
          ADD   AX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   CX, DX
    LOCK  XADD  word ptr [EAX], DX
          MOV   AX, DX
          ADD   AX, CX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Int16; B: Int16): Int16;
asm
{$IFDEF x64}
          MOV   AX, B
    LOCK  XADD  word ptr [A], AX
          ADD   AX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   CX, DX
    LOCK  XADD  word ptr [EAX], DX
          MOV   AX, DX
          ADD   AX, CX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: UInt32; B: UInt32): UInt32;
asm
{$IFDEF x64}
          MOV   EAX, B
    LOCK  XADD  dword ptr [A], EAX
          ADD   EAX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EDX
    LOCK  XADD  dword ptr [EAX], EDX
          MOV   EAX, EDX
          ADD   EAX, ECX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Int32; B: Int32): Int32;
asm
{$IFDEF x64}
          MOV   EAX, B
    LOCK  XADD  dword ptr [A], EAX
          ADD   EAX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EDX
    LOCK  XADD  dword ptr [EAX], EDX
          MOV   EAX, EDX
          ADD   EAX, ECX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedAdd(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}
          MOV   RAX, B
    LOCK  XADD  qword ptr [A], RAX
          ADD   RAX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EBX, dword ptr [B]
          MOV   ECX, dword ptr [B + 4]

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          ADD   EBX, EAX
          ADC   ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}
          MOV   RAX, B
    LOCK  XADD  qword ptr [A], RAX
          ADD   RAX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EBX, dword ptr [B]
          MOV   ECX, dword ptr [B + 4]

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          ADD   EBX, EAX
          ADC   ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Pointer; B: PtrInt): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedAdd(UInt64(A),UInt64(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedAdd(UInt32(A),UInt32(B)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Pointer; B: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedAdd(UInt64(A),UInt64(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedAdd(UInt32(A),UInt32(B)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;


{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked subtraction
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedSub(var A: UInt8; B: UInt8): UInt8;
asm
{$IFDEF x64}
          MOV   AL, B
          NEG   AL
    LOCK  XADD  byte ptr [A], AL
          SUB   AL, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   CL, DL
          NEG   CL
    LOCK  XADD  byte ptr [EAX], CL
          MOV   AL, CL
          SUB   AL, DL
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Int8; B: Int8): Int8;
asm
{$IFDEF x64}
          MOV   AL, B
          NEG   AL
    LOCK  XADD  byte ptr [A], AL
          SUB   AL, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   CL, DL
          NEG   CL
    LOCK  XADD  byte ptr [EAX], CL
          MOV   AL, CL
          SUB   AL, DL
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: UInt16; B: UInt16): UInt16;
asm
{$IFDEF x64}
          MOV   AX, B
          NEG   AX
    LOCK  XADD  word ptr [A], AX
          SUB   AX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   CX, DX
          NEG   CX
    LOCK  XADD  word ptr [EAX], CX
          MOV   AX, CX
          SUB   AX, DX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Int16; B: Int16): Int16;
asm
{$IFDEF x64}
          MOV   AX, B
          NEG   AX
    LOCK  XADD  word ptr [A], AX
          SUB   AX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   CX, DX
          NEG   CX
    LOCK  XADD  word ptr [EAX], CX
          MOV   AX, CX
          SUB   AX, DX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: UInt32; B: UInt32): UInt32;
asm
{$IFDEF x64}
          MOV   EAX, B
          NEG   EAX
    LOCK  XADD  dword ptr [A], EAX
          SUB   EAX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EDX
          NEG   ECX
    LOCK  XADD  dword ptr [EAX], ECX
          MOV   EAX, ECX
          SUB   EAX, EDX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Int32; B: Int32): Int32;
asm
{$IFDEF x64}
          MOV   EAX, B
          NEG   EAX
    LOCK  XADD  dword ptr [A], EAX
          SUB   EAX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EDX
          NEG   ECX
    LOCK  XADD  dword ptr [EAX], ECX
          MOV   EAX, ECX
          SUB   EAX, EDX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedSub(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}
          MOV   RAX, B
          NEG   RAX
    LOCK  XADD  qword ptr [A], RAX
          SUB   RAX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          SUB   EBX, dword ptr [B]
          SBB   ECX, dword ptr [B + 4]

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}
          MOV   RAX, B
          NEG   RAX
    LOCK  XADD  qword ptr [A], RAX
          SUB   RAX, B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          SUB   EBX, dword ptr [B]
          SBB   ECX, dword ptr [B + 4]

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Pointer; B: PtrInt): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedSub(UInt64(A),UInt64(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedSub(UInt32(A),UInt32(B)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Pointer; B: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedSub(UInt64(A),UInt64(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedSub(UInt32(A),UInt32(B)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;


{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked negation
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedNeg(var I: UInt8): UInt8;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AL, byte ptr [I]

          MOV   DL, AL
          NEG   DL

    LOCK  CMPXCHG byte ptr [I], DL

          JNZ   @TryOutStart

          MOV   AL, DL
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   DL, AL
          NEG   DL

    LOCK  CMPXCHG byte ptr [ECX], DL

          JNZ   @TryOutStart

          MOV   AL, DL
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: Int8): Int8;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AL, byte ptr [I]

          MOV   DL, AL
          NEG   DL

    LOCK  CMPXCHG byte ptr [I], DL

          JNZ   @TryOutStart

          MOV   AL, DL
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   DL, AL
          NEG   DL

    LOCK  CMPXCHG byte ptr [ECX], DL

          JNZ   @TryOutStart

          MOV   AL, DL
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: UInt16): UInt16;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AX, word ptr [I]

          MOV   DX, AX
          NEG   DX

    LOCK  CMPXCHG word ptr [I], DX

          JNZ   @TryOutStart

          MOV   AX, DX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   DX, AX
          NEG   DX

    LOCK  CMPXCHG word ptr [ECX], DX

          JNZ   @TryOutStart

          MOV   AX, DX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: Int16): Int16;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AX, word ptr [I]

          MOV   DX, AX
          NEG   DX

    LOCK  CMPXCHG word ptr [I], DX

          JNZ   @TryOutStart

          MOV   AX, DX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   DX, AX
          NEG   DX

    LOCK  CMPXCHG word ptr [ECX], DX

          JNZ   @TryOutStart

          MOV   AX, DX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: UInt32): UInt32;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   EAX, dword ptr [I]

          MOV   EDX, EAX
          NEG   EDX

    LOCK  CMPXCHG dword ptr [I], EDX

          JNZ   @TryOutStart

          MOV   EAX, EDX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EDX, EAX
          NEG   EDX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

          MOV   EAX, EDX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: Int32): Int32;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   EAX, dword ptr [I]

          MOV   EDX, EAX
          NEG   EDX

    LOCK  CMPXCHG dword ptr [I], EDX

          JNZ   @TryOutStart

          MOV   EAX, EDX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EDX, EAX
          NEG   EDX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

          MOV   EAX, EDX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedNeg(var I: UInt64): UInt64;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   RAX, qword ptr [I]

          MOV   RDX, RAX
          NEG   RDX

    LOCK  CMPXCHG qword ptr [I], RDX

          JNZ   @TryOutStart

          MOV   RAX, RDX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          XOR   EBX, EBX
          XOR   ECX, ECX

          SUB   EBX, EAX
          SBB   ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX          
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: Int64): Int64;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   RAX, qword ptr [I]

          MOV   RDX, RAX
          NEG   RDX

    LOCK  CMPXCHG qword ptr [I], RDX

          JNZ   @TryOutStart

          MOV   RAX, RDX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          XOR   EBX, EBX
          XOR   ECX, ECX

          SUB   EBX, EAX
          SBB   ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX          
{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNeg(var I: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedNeg(UInt64(I)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedNeg(UInt32(I)));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{$IFDEF OverflowChecks}{$Q+}{$ENDIF}


{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked logical not
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedNot(var I: UInt8): UInt8;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AL, byte ptr [I]

          MOV   DL, AL
          NOT   DL

    LOCK  CMPXCHG byte ptr [I], DL

          JNZ   @TryOutStart

          MOV   AL, DL
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   DL, AL
          NOT   DL

    LOCK  CMPXCHG byte ptr [ECX], DL

          JNZ   @TryOutStart

          MOV   AL, DL
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: Int8): Int8;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AL, byte ptr [I]

          MOV   DL, AL
          NOT   DL

    LOCK  CMPXCHG byte ptr [I], DL

          JNZ   @TryOutStart

          MOV   AL, DL
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   DL, AL
          NOT   DL

    LOCK  CMPXCHG byte ptr [ECX], DL

          JNZ   @TryOutStart

          MOV   AL, DL
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: UInt16): UInt16;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AX, word ptr [I]

          MOV   DX, AX
          NOT   DX

    LOCK  CMPXCHG word ptr [I], DX

          JNZ   @TryOutStart

          MOV   AX, DX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   DX, AX
          NOT   DX

    LOCK  CMPXCHG word ptr [ECX], DX

          JNZ   @TryOutStart

          MOV   AX, DX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: Int16): Int16;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AX, word ptr [I]

          MOV   DX, AX
          NOT   DX

    LOCK  CMPXCHG word ptr [I], DX

          JNZ   @TryOutStart

          MOV   AX, DX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   DX, AX
          NOT   DX

    LOCK  CMPXCHG word ptr [ECX], DX

          JNZ   @TryOutStart

          MOV   AX, DX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: UInt32): UInt32;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   EAX, dword ptr [I]

          MOV   EDX, EAX
          NOT   EDX

    LOCK  CMPXCHG dword ptr [I], EDX

          JNZ   @TryOutStart

          MOV   EAX, EDX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EDX, EAX
          NOT   EDX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

          MOV   EAX, EDX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: Int32): Int32;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   EAX, dword ptr [I]

          MOV   EDX, EAX
          NOT   EDX

    LOCK  CMPXCHG dword ptr [I], EDX

          JNZ   @TryOutStart

          MOV   EAX, EDX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EDX, EAX
          NOT   EDX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

          MOV   EAX, EDX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedNot(var I: UInt64): UInt64;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   RAX, qword ptr [I]

          MOV   RDX, RAX
          NOT   RDX

    LOCK  CMPXCHG qword ptr [I], RDX

          JNZ   @TryOutStart

          MOV   RAX, RDX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          NOT   EBX
          NOT   ECX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX          
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: Int64): Int64;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   RAX, qword ptr [I]

          MOV   RDX, RAX
          NOT   RDX

    LOCK  CMPXCHG qword ptr [I], RDX

          JNZ   @TryOutStart

          MOV   RAX, RDX
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          NOT   EBX
          NOT   ECX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX          
{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedNot(var I: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedNot(UInt64(i)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedNot(UInt32(i)));
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
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          AND   R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

          MOV   AL, R8B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          AND   BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          MOV   AL, BL
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: Int8; B: Int8): Int8;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          AND   R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

          MOV   AL, R8B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          AND   BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          MOV   AL, BL
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: UInt16; B: UInt16): UInt16;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          AND   R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

          MOV   AX, R8W
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          AND   BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          MOV   AX, BX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: Int16; B: Int16): Int16;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          AND   R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

          MOV   AX, R8W
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          AND   BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          MOV   AX, BX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: UInt32; B: UInt32): UInt32;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          AND   R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

          MOV   EAX, R8D
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          AND   EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          MOV   EAX, EBX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: Int32; B: Int32): Int32;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          AND   R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

          MOV   EAX, R8D
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          AND   EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          MOV   EAX, EBX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedAnd(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          AND   R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

          MOV   RAX, R8
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, dword ptr [B]
          MOV   ECX, dword ptr [B + 4]

          AND   EBX, EAX
          AND   ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          AND   R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

          MOV   RAX, R8
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, dword ptr [B]
          MOV   ECX, dword ptr [B + 4]

          AND   EBX, EAX
          AND   ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAnd(var A: Pointer; B: Pointer): Pointer;
begin 
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedAnd(UInt64(A),UInt64(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedAnd(UInt32(A),UInt32(B)));
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
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          OR    R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

          MOV   AL, R8B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          OR    BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          MOV   AL, BL
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: Int8; B: Int8): Int8;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          OR    R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

          MOV   AL, R8B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          OR    BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          MOV   AL, BL
          
          POP   EBX
{$ENDIF}
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: UInt16; B: UInt16): UInt16;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          OR    R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

          MOV   AX, R8W
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          OR    BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          MOV   AX, BX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: Int16; B: Int16): Int16;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          OR    R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

          MOV   AX, R8W
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          OR    BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          MOV   AX, BX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: UInt32; B: UInt32): UInt32;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          OR    R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

          MOV   EAX, R8D
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          OR    EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          MOV   EAX, EBX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: Int32; B: Int32): Int32;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          OR    R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

          MOV   EAX, R8D
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          OR    EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          MOV   EAX, EBX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedOr(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          OR    R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

          MOV   RAX, R8
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, dword ptr [B]
          MOV   ECX, dword ptr [B + 4]

          OR    EBX, EAX
          OR    ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          OR    R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

          MOV   RAX, R8
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, dword ptr [B]
          MOV   ECX, dword ptr [B + 4]

          OR    EBX, EAX
          OR    ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedOr(var A: Pointer; B: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedOr(UInt64(A),UInt64(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedOr(UInt32(A),UInt32(B)));
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
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          XOR   R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

          MOV   AL, R8B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          XOR   BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          MOV   AL, BL
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: Int8; B: Int8): Int8;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          XOR   R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

          MOV   AL, R8B
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          XOR   BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          MOV   AL, BL
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: UInt16; B: UInt16): UInt16;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          XOR   R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

          MOV   AX, R8W
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          XOR   BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          MOV   AX, BX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: Int16; B: Int16): Int16;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          XOR   R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

          MOV   AX, R8W
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          XOR   BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          MOV   AX, BX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: UInt32; B: UInt32): UInt32;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          XOR   R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

          MOV   EAX, R8D
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          XOR   EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          MOV   EAX, EBX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: Int32; B: Int32): Int32;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          XOR   R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

          MOV   EAX, R8D
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          XOR   EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          MOV   EAX, EBX
          
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedXor(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          XOR   R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

          MOV   RAX, R8
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, dword ptr [B]
          MOV   ECX, dword ptr [B + 4]

          XOR   EBX, EAX
          XOR   ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}
    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          XOR   R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

          MOV   RAX, R8
{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, dword ptr [B]
          MOV   ECX, dword ptr [B + 4]

          XOR   EBX, EAX
          XOR   ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          MOV   EAX, EBX
          MOV   EDX, ECX

          POP   EDI
          POP   EBX
{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedXor(var A: Pointer; B: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(InterlockedXor(UInt32(A),UInt32(B)));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(InterlockedXor(UInt32(A),UInt32(B)));
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

{$IFDEF OverflowChecks}{$Q-}{$ENDIF}

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
                       Interlocked exchange and negation
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeNeg(var I: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG8(I,UInt8(-Int8(Result)),Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int8(_iCMPXCHG8(UInt8(I),UInt8(-Result),UInt8(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG16(I,UInt16(-Int16(Result)),Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int16(_iCMPXCHG16(UInt16(I),UInt16(-Result),UInt16(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG32(I,UInt32(-Int32(Result)),Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int32(_iCMPXCHG32(UInt32(I),UInt32(-Result),UInt32(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedExchangeNeg(var I: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG64(I,UInt64(-Int64(Result)),Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int64(_iCMPXCHG64(UInt64(I),UInt64(-Result),UInt64(Result),Exchanged)) = Result;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(I),UInt64(-Int64(Result)),UInt64(Result),Exchanged)) = Result;
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(I),UInt32(-Int32(Result)),UInt32(Result),Exchanged)) = Result;
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;

{$IFDEF OverflowChecks}{$Q+}{$ENDIF}


{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical not
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeNot(var I: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG8(I,not Result,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int8(_iCMPXCHG8(UInt8(I),UInt8(not Result),UInt8(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG16(I,not Result,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int16(_iCMPXCHG16(UInt16(I),UInt16(not Result),UInt16(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG32(I,not Result,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int32(_iCMPXCHG32(UInt32(I),UInt32(not Result),UInt32(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedExchangeNot(var I: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG64(I,not Result,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int64(_iCMPXCHG64(UInt64(I),UInt64(not Result),UInt64(Result),Exchanged)) = Result;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(I),not UInt64(Result),UInt64(Result),Exchanged)) = Result;
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(I),not UInt32(Result),UInt32(Result),Exchanged)) = Result;
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;


{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical and
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeAnd(var A: UInt8; B: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG8(A,Result and B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: Int8; B: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int8(_iCMPXCHG8(UInt8(A),UInt8(Result and B),UInt8(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: UInt16; B: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG16(A,Result and B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: Int16; B: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int16(_iCMPXCHG16(UInt16(A),UInt16(Result and B),UInt16(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: UInt32; B: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG32(A,Result and B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: Int32; B: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int32(_iCMPXCHG32(UInt32(A),UInt32(Result and B),UInt32(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedExchangeAnd(var A: UInt64; B: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG64(A,Result and B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: Int64; B: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int64(_iCMPXCHG64(UInt64(A),UInt64(Result and B),UInt64(Result),Exchanged)) = Result;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: Pointer; B: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(A),UInt64(Result) and UInt64(B),UInt64(Result),Exchanged)) = Result;
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(A),UInt32(Result) and UInt32(B),UInt32(Result),Exchanged)) = Result;
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;


{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical or
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeOr(var A: UInt8; B: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG8(A,Result or B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: Int8; B: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int8(_iCMPXCHG8(UInt8(A),UInt8(Result or B),UInt8(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: UInt16; B: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG16(A,Result or B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: Int16; B: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int16(_iCMPXCHG16(UInt16(A),UInt16(Result or B),UInt16(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: UInt32; B: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG32(A,Result or B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: Int32; B: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int32(_iCMPXCHG32(UInt32(A),UInt32(Result or B),UInt32(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedExchangeOr(var A: UInt64; B: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG64(A,Result or B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: Int64; B: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int64(_iCMPXCHG64(UInt64(A),UInt64(Result or B),UInt64(Result),Exchanged)) = Result;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: Pointer; B: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(A),UInt64(Result) or UInt64(B),UInt64(Result),Exchanged)) = Result;
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(A),UInt32(Result) or UInt32(B),UInt32(Result),Exchanged)) = Result;
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;


{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical xor
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeXor(var A: UInt8; B: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG8(A,Result xor B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: Int8; B: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int8(_iCMPXCHG8(UInt8(A),UInt8(Result xor B),UInt8(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: UInt16; B: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG16(A,Result xor B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: Int16; B: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int16(_iCMPXCHG16(UInt16(A),UInt16(Result xor B),UInt16(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: UInt32; B: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG32(A,Result xor B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: Int32; B: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int32(_iCMPXCHG32(UInt32(A),UInt32(Result xor B),UInt32(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedExchangeXor(var A: UInt64; B: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until _iCMPXCHG64(A,Result xor B,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: Int64; B: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
until Int64(_iCMPXCHG64(UInt64(A),UInt64(Result xor B),UInt64(Result),Exchanged)) = Result;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: Pointer; B: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := A;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(A),UInt64(Result) xor UInt64(B),UInt64(Result),Exchanged)) = Result;
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(A),UInt32(Result) xor UInt32(B),UInt32(Result),Exchanged)) = Result;
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;


{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked bit test
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedBitTest(var I: UInt8; Bit: Integer): Boolean;
begin
Result := ((_iXADD8(I,0) shr (Bit and 7)) and 1) <> 0;
end;


{===============================================================================
--------------------------------------------------------------------------------
                          Interlocked bit test and set
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedBitTestAndSet(var I: UInt8; Bit: Integer): Boolean;
var
  Mask,Temp:  UInt8;
  Exchanged:  ByteBool;
begin
Mask := UInt8(1 shl (Bit and 7));
repeat
  Temp := I;
until _iCMPXCHG8(I,Temp or Mask,Temp,Exchanged) = Temp;
Result := (Temp and Mask) <> 0;
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
                                Interlocked load
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedLoad(var I: UInt8): UInt8;
begin
Result := _iXADD8(I,0);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: Int8): Int8;
begin
Result := _iXADD8(UInt8(I),0);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: UInt16): UInt16;
begin
Result := _iXADD16(I,0);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: Int16): Int16;
begin
Result := _iXADD16(UInt16(I),0);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: UInt32): UInt32;
begin
Result := _iXADD32(I,0);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: Int32): Int32;
begin
Result := _iXADD32(UInt32(I),0);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedLoad(var I: UInt64): UInt64;
begin
Result := _iXADD64(I,0);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: Int64): Int64;
begin
Result := _iXADD64(UInt64(I),0);
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: Pointer): Pointer;
begin
{$IF SizeOf(Pointer) = 8}
  Result := Pointer(_iXADD64(UInt64(I),0));
{$ELSEIF SizeOf(Pointer) = 4}
  Result := Pointer(_iXADD32(UInt32(I),0));
{$ELSE}
  {$MESSAGE FATAL 'Unsupported size of pointer.'}
{$IFEND}
end;


{===============================================================================
--------------------------------------------------------------------------------
                               Interlocked store                                                               
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedStore(var I: UInt8; NewValue: UInt8): UInt8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG8(I,NewValue,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: Int8; NewValue: Int8): Int8;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int8(_iCMPXCHG8(UInt8(I),UInt8(NewValue),UInt8(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: UInt16; NewValue: UInt16): UInt16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG16(I,NewValue,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: Int16; NewValue: Int16): Int16;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int16(_iCMPXCHG16(UInt16(I),UInt16(NewValue),UInt16(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: UInt32; NewValue: UInt32): UInt32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG32(I,NewValue,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: Int32; NewValue: Int32): Int32;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int32(_iCMPXCHG32(UInt32(I),UInt32(NewValue),UInt32(Result),Exchanged)) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF AllowVal64}

Function InterlockedStore(var I: UInt64; NewValue: UInt64): UInt64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until _iCMPXCHG64(I,NewValue,Result,Exchanged) = Result;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: Int64; NewValue: Int64): Int64;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
until Int64(_iCMPXCHG64(UInt64(I),UInt64(NewValue),UInt64(Result),Exchanged)) = Result;
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: Pointer; NewValue: Pointer): Pointer;
var
  Exchanged:  ByteBool;
begin
repeat
  Result := I;
{$IF SizeOf(Pointer) = 8}
until Pointer(_iCMPXCHG64(UInt64(I),UInt64(NewValue),UInt64(Result),Exchanged)) = Result;
{$ELSEIF SizeOf(Pointer) = 4}
until Pointer(_iCMPXCHG32(UInt32(I),UInt32(NewValue),UInt32(Result),Exchanged)) = Result;
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
  //If not Info.ProcessorFeatures.CMPXCHG16B    
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

initialization
  Initialize;

end.

