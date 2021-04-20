{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  InterlockedOps

    This library provides a set of functions, each performing an atomic
    operation on a variable - that is, each function is guaranteed to complete
    its operation in a thread-safe manner.

    It has been created as a replacement and extension of WinAPI-provided
    interlocked functions, but can be used on any system.
    Note that some functions, although equally named, behaves differently than
    those from WinAPI - see description of each function for details.

      WARNING - this entire library is implemented in assembly, and because of
                that, it can only be compiled for x86 (IA-32) and x86-64 (AMD64)
                processors.

    Functions for 8bit, 16bit, 32bit and 64bit integer variables, both signed
    and unsigned, are implemented.

    64bit variants are available in 32bit environment only when symbol
    EnableVal64onSys32 is defined (see symbols define section for more
    information). In 64bit environment, they are always available.

    There are also some funtions accepting 128bit variables, but these are only
    available in 64bit environment and only when symbol EnableVal128 is defined.

    Unless noted otherwise in function description, there are no requirements
    for memory alignment of any of the passed parameters (as-per Intel
    Developers Manual, which explicitly states "The integrity of a bus lock is
    not affected by the alignment of the memory field.").

    Note that upon return of any of the provided function, the accessed variable
    can already have a different value than expected if it was accessed by other
    thread(s). Whatever the function returns is a state that was valid during
    the internal lock.

  Version 1.0 (2021-04-20)

  Last change 2021-04-20

  ©2021 František Milt

  Contacts:
    František Milt: frantisek.milt@gmail.com

  Support:
    If you find this code useful, please consider supporting its author(s) by
    making a small donation using the following link(s):

      https://www.paypal.me/FMilt

  Changelog:
    For detailed changelog and history please refer to this git repository:

      github.com/TheLazyTomcat/Lib.InterlockedOps

  Dependencies:
    AuxTypes    - github.com/TheLazyTomcat/Lib.AuxTypes
    SimpleCPUID - github.com/TheLazyTomcat/Lib.SimpleCPUID

===============================================================================}
unit InterlockedOps;
{
  InterlockedOps_PurePascal

  If you want to compile this unit without ASM, don't want to or cannot define
  PurePascal for the entire project and at the same time you don't want to or
  cannot make changes to this unit, define this symbol for the entire project
  and this unit will be compiled in PurePascal mode.

    NOTE - this unit cannot be compiled without asm, but there it is for the
           sake of completeness.
}
{$IFDEF InterlockedOps_PurePascal}
  {$DEFINE PurePascal}
{$ENDIF}

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
  {$DEFINE FPC_DisableWarns}
  {$MACRO ON}
{$ENDIF}
{$H+}

//------------------------------------------------------------------------------
{
  EnableVal64onSys32

  When defined, 64bit variants of all functions (that is, variants working with
  64bit parameters) are provided in 32bit environment. When not defined, these
  variants are available only in 64bit environment.

  Since implementing proper locking of 64bit primitive in 32bit mode is
  depending on instructions CMPXCHG8B and CMOV, which are not present on very
  old processors, this symbol is here to disable such code if there is a need
  to run this library on legacy hardware.

  Note that whether the unit was compiled with support for 64bit variables
  can be discerned from public constant ILO_64BIT_VARS - when true, the 64bit
  variants are provided, otherwise they are not.

    WARNING - when binary compiled with this symbol defined is run on hardware
              that does not support needed instructions, then an exception of
              type EILOUnsupportedInstruction is raised during unit
              initialization.

  By default enabled.
}
{$DEFINE EnableVal64onSys32}

{
  EnableVal128

  When enabled, 128bit variants of function InterlockedCompareExchange are
  provided, otherwise they are not.

  Whether the unit was compiled with support for 128bit variables can be
  discerned from public constant ILO_128BIT_VARS - when true, the 128bit
  variants are provided, otherwise they are not.

    WARNING - these functions are available only in 64bit mode, never in 32bit
              mode. Therefore, this symbol has no effect in 32bit mode.

    WARNING - when binary compiled with this symbol defined is run on hardware
              that does not support needed instruction, then an exception of
              type EILOUnsupportedInstruction is raised during unit
              initialization.

  By default enabled.
}
{$DEFINE EnableVal128}

//------------------------------------------------------------------------------
// do not touch following define checks

{$IF Defined(EnableVal64onSys32) or Defined(x64)}
  {$DEFINE IncludeVal64}
{$IFEND}

{$IF Defined(EnableVal128) and Defined(x64)}
  {$DEFINE IncludeVal128}
{$IFEND}

{$IFDEF PurePascal}
  {$MESSAGE WARN 'This unit cannot be compiled in PurePascal mode.'}
{$ENDIF}

interface

uses
  SysUtils,
  AuxTypes;

{===============================================================================
    Informative public constants
===============================================================================}
const
  ILO_64BIT_VARS  = {$IFDEF IncludeVal64}True{$ELSE}False{$ENDIF};
  ILO_128BIT_VARS = {$IFDEF IncludeVal128}True{$ELSE}False{$ENDIF};

{===============================================================================
    Some helper types
===============================================================================}
{
  Type UInt128 is here only to provide 128 bits long type that could be used in
  calls to 128bit variants of provided functions.
}
type
  UInt128 = packed record
    case Integer of
      0:(Low:     UInt64;
         High:    UInt64);
      1:(QWords:  array[0..1] of UInt64);
      2:(DWords:  array[0..3] of UInt32);
      3:(Words:   array[0..7] of UInt16);
      4:(Bytes:   array[0..15] of UInt8);
  end;
   PUInt128 =  ^UInt128;
  PPUInt128 = ^PUInt128;

{===============================================================================
    Library-specific exception classes
===============================================================================}
type
  EILOException = class(Exception);

  EILOUnsupportedInstruction = class(EILOException);

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked increment
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedIncrement

    Increments I by one and returns the resulting (incremented) value.
}
Function InterlockedIncrement(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedIncrement(var I: Int8): Int8; overload; register; assembler;

Function InterlockedIncrement(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedIncrement(var I: Int16): Int16; overload; register; assembler;

Function InterlockedIncrement(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedIncrement(var I: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedIncrement(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedIncrement(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedIncrement(var I: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked decrement
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedDecrement

    Decrements I by one and returns the resulting (decremented) value.
}
Function InterlockedDecrement(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedDecrement(var I: Int8): Int8; overload; register; assembler;

Function InterlockedDecrement(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedDecrement(var I: Int16): Int16; overload; register; assembler;

Function InterlockedDecrement(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedDecrement(var I: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedDecrement(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedDecrement(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedDecrement(var I: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked addition
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedAdd

    Sets A to a sum of A and B and returns the resulting value.
}
Function InterlockedAdd(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedAdd(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedAdd(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedAdd(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedAdd(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedAdd(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedAdd(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedAdd(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedAdd(var A: Pointer; B: PtrInt): Pointer; overload; register; assembler;
Function InterlockedAdd(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked subtraction
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedSub

    Subtracts B from A and returns the resulting value.
}
Function InterlockedSub(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedSub(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedSub(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedSub(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedSub(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedSub(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedSub(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedSub(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedSub(var A: Pointer; B: PtrInt): Pointer; overload; register; assembler;
Function InterlockedSub(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked negation
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedNeg

    Negates (changes sign) of I and returns the resulting value.

    Note that unsigned integers are treated as signed. For example UInt8(255)
    is seen as Int8(-1), and its negative is therefore UInt8(1).
}
Function InterlockedNeg(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedNeg(var I: Int8): Int8; overload; register; assembler;

Function InterlockedNeg(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedNeg(var I: Int16): Int16; overload; register; assembler;

Function InterlockedNeg(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedNeg(var I: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedNeg(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedNeg(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedNeg(var I: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked logical not
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedNot

    Performs logical NOT (flips all bits) of I and returns the resulting value.
}
Function InterlockedNot(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedNot(var I: Int8): Int8; overload; register; assembler;

Function InterlockedNot(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedNot(var I: Int16): Int16; overload; register; assembler;

Function InterlockedNot(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedNot(var I: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedNot(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedNot(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedNot(var I: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                            Interlocked logical and
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedAnd

    Performs logical AND of A and B and returns the resulting value.

    WARNING - this function differs from InterlockedAnd provided by WinAPI.
              There, it returns original value of the variable, here it returns
              the resulting value.
              WinAPI behavior is provided by function InterlockedExchangeAnd.
}
Function InterlockedAnd(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedAnd(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedAnd(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedAnd(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedAnd(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedAnd(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedAnd(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedAnd(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedAnd(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked logical or
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedOr

    Performs logical OR of A and B and returns the resulting value.

    WARNING - this function differs from InterlockedOr provided by WinAPI.
              There, it returns original value of the variable, here it returns
              the resulting value.
              WinAPI behavior is provided by function InterlockedExchangeOr.
}
Function InterlockedOr(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedOr(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedOr(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedOr(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedOr(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedOr(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedOr(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedOr(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedOr(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked logical xor
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedXor

    Performs logical XOR of A and B and returns the resulting value.

    WARNING - this function differs from InterlockedXor provided by WinAPI.
              There, it returns original value of the variable, here it returns
              the resulting value.
              WinAPI behavior is provided by function InterlockedExchangeXor.
}
Function InterlockedXor(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedXor(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedXor(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedXor(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedXor(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedXor(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedXor(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedXor(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedXor(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked exchange
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedExchange

    Sets A to a value of B and returns original value of A.
}
Function InterlockedExchange(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedExchange(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedExchange(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedExchange(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedExchange(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedExchange(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedExchange(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedExchange(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedExchange(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                          Interlocked exchange and add
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedExchangeAdd

    Sets A to a sum of A and B and returns original value of A.
}
Function InterlockedExchangeAdd(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedExchangeAdd(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedExchangeAdd(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedExchangeAdd(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedExchangeAdd(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedExchangeAdd(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedExchangeAdd(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedExchangeAdd(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedExchangeAdd(var A: Pointer; B: PtrInt): Pointer; overload; register; assembler;
Function InterlockedExchangeAdd(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                       Interlocked exchange and subtract
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedExchangeSub

    Subtracts B from A and returns original value of A.
}
Function InterlockedExchangeSub(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedExchangeSub(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedExchangeSub(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedExchangeSub(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedExchangeSub(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedExchangeSub(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedExchangeSub(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedExchangeSub(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedExchangeSub(var A: Pointer; B: PtrInt): Pointer; overload; register; assembler;
Function InterlockedExchangeSub(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                       Interlocked exchange and negation
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedExchangeNeg

    Negates (changes sign) of I and returns its original value.

    Note that unsigned integers are treated as signed. For example UInt8(255)
    is seen as Int8(-1), and its negative is therefore UInt8(1).
}
Function InterlockedExchangeNeg(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedExchangeNeg(var I: Int8): Int8; overload; register; assembler;

Function InterlockedExchangeNeg(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedExchangeNeg(var I: Int16): Int16; overload; register; assembler;

Function InterlockedExchangeNeg(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedExchangeNeg(var I: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedExchangeNeg(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedExchangeNeg(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedExchangeNeg(var I: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical not
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedExchangeNot

    Performs logical NOT (flips all bits) of I and returns its original value.
}
Function InterlockedExchangeNot(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedExchangeNot(var I: Int8): Int8; overload; register; assembler;

Function InterlockedExchangeNot(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedExchangeNot(var I: Int16): Int16; overload; register; assembler;

Function InterlockedExchangeNot(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedExchangeNot(var I: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedExchangeNot(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedExchangeNot(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedExchangeNot(var I: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical and
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedExchangeAnd

    Performs logical AND of A and B and returns original value of A.
}
Function InterlockedExchangeAnd(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedExchangeAnd(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedExchangeAnd(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedExchangeAnd(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedExchangeAnd(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedExchangeAnd(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedExchangeAnd(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedExchangeAnd(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedExchangeAnd(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical or
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedExchangeOr

    Performs logical OR of A and B and returns original value of A.
}
Function InterlockedExchangeOr(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedExchangeOr(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedExchangeOr(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedExchangeOr(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedExchangeOr(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedExchangeOr(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedExchangeOr(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedExchangeOr(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedExchangeOr(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical xor
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedExchangeXor

    Performs logical XOR of A and B and returns original value of A.
}
Function InterlockedExchangeXor(var A: UInt8; B: UInt8): UInt8; overload; register; assembler;
Function InterlockedExchangeXor(var A: Int8; B: Int8): Int8; overload; register; assembler;

Function InterlockedExchangeXor(var A: UInt16; B: UInt16): UInt16; overload; register; assembler;
Function InterlockedExchangeXor(var A: Int16; B: Int16): Int16; overload; register; assembler;

Function InterlockedExchangeXor(var A: UInt32; B: UInt32): UInt32; overload; register; assembler;
Function InterlockedExchangeXor(var A: Int32; B: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedExchangeXor(var A: UInt64; B: UInt64): UInt64; overload; register; assembler;
Function InterlockedExchangeXor(var A: Int64; B: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedExchangeXor(var A: Pointer; B: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                        Interlocked compare and exchange                         
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedCompareExchange

    Compares value of Destination with Comparand. When they are equal, the
    Destination is set to a value passed in Exchange. If they do not match,
    then nothing is done.
    Whether the exchange took place or not is indicated by value returned in
    Exchanged (True = exchange was performed).
    Returns original value of Destination.

    WARNING - 128bit variant requires the value Destination to be located in
              memory at 128bit-aligned address, otherwise it will fail with an
              exception.
}
Function InterlockedCompareExchange(var Destination: UInt8; Exchange,Comparand: UInt8; out Exchanged: Boolean): UInt8; overload; register; assembler;
Function InterlockedCompareExchange(var Destination: Int8; Exchange,Comparand: Int8; out Exchanged: Boolean): Int8; overload; register; assembler;

Function InterlockedCompareExchange(var Destination: UInt16; Exchange,Comparand: UInt16; out Exchanged: Boolean): UInt16; overload; register; assembler;
Function InterlockedCompareExchange(var Destination: Int16; Exchange,Comparand: Int16; out Exchanged: Boolean): Int16; overload; register; assembler;

Function InterlockedCompareExchange(var Destination: UInt32; Exchange,Comparand: UInt32; out Exchanged: Boolean): UInt32; overload; register; assembler;
Function InterlockedCompareExchange(var Destination: Int32; Exchange,Comparand: Int32; out Exchanged: Boolean): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedCompareExchange(var Destination: UInt64; Exchange,Comparand: UInt64; out Exchanged: Boolean): UInt64; overload; register; assembler;
Function InterlockedCompareExchange(var Destination: Int64; Exchange,Comparand: Int64; out Exchanged: Boolean): Int64; overload; register; assembler;
{$ENDIF}

{$IFDEF IncludeVal128}
Function InterlockedCompareExchange(var Destination: UInt128; Exchange,Comparand: UInt128; out Exchanged: Boolean): UInt128; overload; register; assembler;
{$ENDIF}

Function InterlockedCompareExchange(var Destination: Pointer; Exchange,Comparand: Pointer; out Exchanged: Boolean): Pointer; overload; register; assembler;

//------------------------------------------------------------------------------
{
  InterlockedCompareExchange

    Compares value of Destination with Comparand. When they are equal, the
    Destination is set to a value passed in Exchange. If they do not match,
    then nothing is done.
    Returns original value of Destination.

    WARNING - 128bit variant requires the value Destination to be located in
              memory at 128bit-aligned address, otherwise it will fail with an
              exception.
}
Function InterlockedCompareExchange(var Destination: UInt8; Exchange,Comparand: UInt8): UInt8; overload; register; assembler;
Function InterlockedCompareExchange(var Destination: Int8; Exchange,Comparand: Int8): Int8; overload; register; assembler;

Function InterlockedCompareExchange(var Destination: UInt16; Exchange,Comparand: UInt16): UInt16; overload; register; assembler;
Function InterlockedCompareExchange(var Destination: Int16; Exchange,Comparand: Int16): Int16; overload; register; assembler;

Function InterlockedCompareExchange(var Destination: UInt32; Exchange,Comparand: UInt32): UInt32; overload; register; assembler;
Function InterlockedCompareExchange(var Destination: Int32; Exchange,Comparand: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedCompareExchange(var Destination: UInt64; Exchange,Comparand: UInt64): UInt64; overload; register; assembler;
Function InterlockedCompareExchange(var Destination: Int64; Exchange,Comparand: Int64): Int64; overload; register; assembler;
{$ENDIF}

{$IFDEF IncludeVal128}
Function InterlockedCompareExchange(var Destination: UInt128; Exchange,Comparand: UInt128): UInt128; overload; register; assembler;
{$ENDIF}

Function InterlockedCompareExchange(var Destination: Pointer; Exchange,Comparand: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked bit test
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedBitTest

    Returns value of bit (True = 1/set, False = 0/clear) selected by a parameter
    Bit in variable I.
}
Function InterlockedBitTest(var I: UInt8; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTest(var I: Int8; Bit: Integer): Boolean; overload; register; assembler;

Function InterlockedBitTest(var I: UInt16; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTest(var I: Int16; Bit: Integer): Boolean; overload; register; assembler;

Function InterlockedBitTest(var I: UInt32; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTest(var I: Int32; Bit: Integer): Boolean; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedBitTest(var I: UInt64; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTest(var I: Int64; Bit: Integer): Boolean; overload; register; assembler;
{$ENDIF}

Function InterlockedBitTest(var I: Pointer; Bit: Integer): Boolean; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                          Interlocked bit test and set
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedBitTestAndSet

    Sets a bit (changes it to 1) selected by a parameter Bit in variable I and
    returns original value of this bit.
}
Function InterlockedBitTestAndSet(var I: UInt8; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndSet(var I: Int8; Bit: Integer): Boolean; overload; register; assembler;

Function InterlockedBitTestAndSet(var I: UInt16; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndSet(var I: Int16; Bit: Integer): Boolean; overload; register; assembler;

Function InterlockedBitTestAndSet(var I: UInt32; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndSet(var I: Int32; Bit: Integer): Boolean; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedBitTestAndSet(var I: UInt64; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndSet(var I: Int64; Bit: Integer): Boolean; overload; register; assembler;
{$ENDIF}

Function InterlockedBitTestAndSet(var I: Pointer; Bit: Integer): Boolean; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                         Interlocked bit test and reset
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedBitTestAndReset

    Resets/clears a bit (changes it to 0) selected by a parameter Bit in
    variable I and returns original value of this bit.
}
Function InterlockedBitTestAndReset(var I: UInt8; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndReset(var I: Int8; Bit: Integer): Boolean; overload; register; assembler;

Function InterlockedBitTestAndReset(var I: UInt16; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndReset(var I: Int16; Bit: Integer): Boolean; overload; register; assembler;

Function InterlockedBitTestAndReset(var I: UInt32; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndReset(var I: Int32; Bit: Integer): Boolean; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedBitTestAndReset(var I: UInt64; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndReset(var I: Int64; Bit: Integer): Boolean; overload; register; assembler;
{$ENDIF}

Function InterlockedBitTestAndReset(var I: Pointer; Bit: Integer): Boolean; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked bit test and complement
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedBitTestAndComplement

    Complements a bit (swiches its value - if it was 0, it will become 1 and
    vice-versa) selected by a parameter Bit in variable I and returns original
    value of this bit.
}
Function InterlockedBitTestAndComplement(var I: UInt8; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndComplement(var I: Int8; Bit: Integer): Boolean; overload; register; assembler;

Function InterlockedBitTestAndComplement(var I: UInt16; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndComplement(var I: Int16; Bit: Integer): Boolean; overload; register; assembler;

Function InterlockedBitTestAndComplement(var I: UInt32; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndComplement(var I: Int32; Bit: Integer): Boolean; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedBitTestAndComplement(var I: UInt64; Bit: Integer): Boolean; overload; register; assembler;
Function InterlockedBitTestAndComplement(var I: Int64; Bit: Integer): Boolean; overload; register; assembler;
{$ENDIF}

Function InterlockedBitTestAndComplement(var I: Pointer; Bit: Integer): Boolean; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                                Interlocked load
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedLoad

    Atomically obtains value of I and returns it.
}
Function InterlockedLoad(var I: UInt8): UInt8; overload; register; assembler;
Function InterlockedLoad(var I: Int8): Int8; overload; register; assembler;

Function InterlockedLoad(var I: UInt16): UInt16; overload; register; assembler;
Function InterlockedLoad(var I: Int16): Int16; overload; register; assembler;

Function InterlockedLoad(var I: UInt32): UInt32; overload; register; assembler;
Function InterlockedLoad(var I: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedLoad(var I: UInt64): UInt64; overload; register; assembler;
Function InterlockedLoad(var I: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedLoad(var I: Pointer): Pointer; overload; register; assembler;

{===============================================================================
--------------------------------------------------------------------------------
                               Interlocked store                                                               
--------------------------------------------------------------------------------
===============================================================================}
{
  InterlockedStore

    Sets variable I to a value passed in parameter NewValue and returns
    original value of I.
}
Function InterlockedStore(var I: UInt8; NewValue: UInt8): UInt8; overload; register; assembler;
Function InterlockedStore(var I: Int8; NewValue: Int8): Int8; overload; register; assembler;

Function InterlockedStore(var I: UInt16; NewValue: UInt16): UInt16; overload; register; assembler;
Function InterlockedStore(var I: Int16; NewValue: Int16): Int16; overload; register; assembler;

Function InterlockedStore(var I: UInt32; NewValue: UInt32): UInt32; overload; register; assembler;
Function InterlockedStore(var I: Int32; NewValue: Int32): Int32; overload; register; assembler;

{$IFDEF IncludeVal64}
Function InterlockedStore(var I: UInt64; NewValue: UInt64): UInt64; overload; register; assembler;
Function InterlockedStore(var I: Int64; NewValue: Int64): Int64; overload; register; assembler;
{$ENDIF}

Function InterlockedStore(var I: Pointer; NewValue: Pointer): Pointer; overload; register; assembler;

implementation

uses
  SimpleCPUID;

{===============================================================================
--------------------------------------------------------------------------------
                             Interlocked increment                              
--------------------------------------------------------------------------------
===============================================================================}

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

{$IFDEF IncludeVal64}

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
asm
{$IFDEF x64}

          MOV   RDX, 1
    LOCK  XADD  qword ptr [I], RDX
          MOV   RAX, RDX
          INC   RAX

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   EDX, 1
    LOCK  XADD  dword ptr [I], EDX
          MOV   EAX, EDX
          INC   EAX
          
{$ENDIF}
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

{$IFDEF IncludeVal64}

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
asm
{$IFDEF x64}

          MOV   RDX, qword(-1)
    LOCK  XADD  qword ptr [I], RDX
          MOV   RAX, RDX
          DEC   RAX

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   EDX, dword(-1)
    LOCK  XADD  dword ptr [I], EDX
          MOV   EAX, EDX
          DEC   EAX
          
{$ENDIF}
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

{$IFDEF IncludeVal64}

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
asm
{$IFDEF x64}

          MOV   RAX, B
    LOCK  XADD  qword ptr [A], RAX
          ADD   RAX, B

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EDX
    LOCK  XADD  dword ptr [EAX], EDX
          MOV   EAX, EDX
          ADD   EAX, ECX
          
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedAdd(var A: Pointer; B: Pointer): Pointer;
asm
{$IFDEF x64}

          MOV   RAX, B
    LOCK  XADD  qword ptr [A], RAX
          ADD   RAX, B

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EDX
    LOCK  XADD  dword ptr [EAX], EDX
          MOV   EAX, EDX
          ADD   EAX, ECX
          
{$ENDIF}
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

{$IFDEF IncludeVal64}

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
asm
{$IFDEF x64}

          MOV   RAX, B
          NEG   RAX
    LOCK  XADD  qword ptr [A], RAX
          SUB   RAX, B


{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EDX
          NEG   ECX
    LOCK  XADD  dword ptr [EAX], ECX
          MOV   EAX, ECX
          SUB   EAX, EDX
          
{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedSub(var A: Pointer; B: Pointer): Pointer;
asm
{$IFDEF x64}

          MOV   RAX, B
          NEG   RAX
    LOCK  XADD  qword ptr [A], RAX
          SUB   RAX, B


{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EDX
          NEG   ECX
    LOCK  XADD  dword ptr [EAX], ECX
          MOV   EAX, ECX
          SUB   EAX, EDX
          
{$ENDIF}
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

{$IFDEF IncludeVal64}

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

{$IFDEF IncludeVal64}

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

{$IFDEF IncludeVal64}

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

{$IFDEF IncludeVal64}

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

{$IFDEF IncludeVal64}

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


{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked exchange
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchange(var A: UInt8; B: UInt8): UInt8;
asm
    LOCK  XCHG  byte ptr [A], B
          MOV   AL, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: Int8; B: Int8): Int8;
asm
    LOCK  XCHG  byte ptr [A], B
          MOV   AL, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: UInt16; B: UInt16): UInt16;
asm
    LOCK  XCHG  word ptr [A], B
          MOV   AX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: Int16; B: Int16): Int16;
asm
    LOCK  XCHG  word ptr [A], B
          MOV   AX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: UInt32; B: UInt32): UInt32;
asm
    LOCK  XCHG  dword ptr [A], B
          MOV   EAX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: Int32; B: Int32): Int32;
asm
    LOCK  XCHG  dword ptr [A], B
          MOV   EAX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedExchange(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}

    LOCK  XCHG  qword ptr [A], B
          MOV   RAX, B

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EBX, dword ptr [B]
          MOV   ECX, dword ptr [B + 4]

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]          

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}

    LOCK  XCHG  qword ptr [A], B
          MOV   RAX, B

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EBX, dword ptr [B]
          MOV   ECX, dword ptr [B + 4]

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchange(var A: Pointer; B: Pointer): Pointer;
asm
{$IFDEF x64}

    LOCK  XCHG  qword ptr [A], B
          MOV   RAX, B

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    LOCK  XCHG  dword ptr [A], B
          MOV   EAX, B

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                          Interlocked exchange and add
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeAdd(var A: UInt8; B: UInt8): UInt8;
asm
    LOCK  XADD  byte ptr [A], B
          MOV   AL, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int8; B: Int8): Int8;
asm
    LOCK  XADD  byte ptr [A], B
          MOV   AL, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: UInt16; B: UInt16): UInt16;
asm
    LOCK  XADD  word ptr [A], B
          MOV   AX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int16; B: Int16): Int16;
asm
    LOCK  XADD  word ptr [A], B
          MOV   AX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: UInt32; B: UInt32): UInt32;
asm
    LOCK  XADD  dword ptr [A], B
          MOV   EAX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int32; B: Int32): Int32;
asm
    LOCK  XADD  dword ptr [A], B
          MOV   EAX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedExchangeAdd(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}

    LOCK  XADD  qword ptr [A], B
          MOV   RAX, B

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}

    LOCK  XADD  qword ptr [A], B
          MOV   RAX, B

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Pointer; B: PtrInt): Pointer;
asm
{$IFDEF x64}

    LOCK  XADD  qword ptr [A], B
          MOV   RAX, B

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    LOCK  XADD  dword ptr [A], B
          MOV   EAX, B

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAdd(var A: Pointer; B: Pointer): Pointer;
asm
{$IFDEF x64}

    LOCK  XADD  qword ptr [A], B
          MOV   RAX, B

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

    LOCK  XADD  dword ptr [A], B
          MOV   EAX, B

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                       Interlocked exchange and subtract
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeSub(var A: UInt8; B: UInt8): UInt8;
asm
          NEG   B
    LOCK  XADD  byte ptr [A], B
          MOV   AL, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Int8; B: Int8): Int8;
asm
          NEG   B
    LOCK  XADD  byte ptr [A], B
          MOV   AL, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: UInt16; B: UInt16): UInt16;
asm
          NEG   B
    LOCK  XADD  word ptr [A], B
          MOV   AX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Int16; B: Int16): Int16;
asm
          NEG   B
    LOCK  XADD  word ptr [A], B
          MOV   AX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: UInt32; B: UInt32): UInt32;
asm
          NEG   B
    LOCK  XADD  dword ptr [A], B
          MOV   EAX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Int32; B: Int32): Int32;
asm
          NEG   B
    LOCK  XADD  dword ptr [A], B
          MOV   EAX, B
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedExchangeSub(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}

          NEG   B
    LOCK  XADD  qword ptr [A], B
          MOV   RAX, B

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}

          NEG   B
    LOCK  XADD  qword ptr [A], B
          MOV   RAX, B

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Pointer; B: PtrInt): Pointer;
asm
{$IFDEF x64}

          NEG   B
    LOCK  XADD  qword ptr [A], B
          MOV   RAX, B

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          NEG   B
    LOCK  XADD  dword ptr [A], B
          MOV   EAX, B

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeSub(var A: Pointer; B: Pointer): Pointer;
asm
{$IFDEF x64}

          NEG   B
    LOCK  XADD  qword ptr [A], B
          MOV   RAX, B

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          NEG   B
    LOCK  XADD  dword ptr [A], B
          MOV   EAX, B

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                       Interlocked exchange and negation
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeNeg(var I: UInt8): UInt8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [I]

          MOV   DL, AL
          NEG   DL

    LOCK  CMPXCHG byte ptr [I], DL

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   DL, AL
          NEG   DL

    LOCK  CMPXCHG byte ptr [ECX], DL

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: Int8): Int8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [I]

          MOV   DL, AL
          NEG   DL

    LOCK  CMPXCHG byte ptr [I], DL

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   DL, AL
          NEG   DL

    LOCK  CMPXCHG byte ptr [ECX], DL

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: UInt16): UInt16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [I]

          MOV   DX, AX
          NEG   DX

    LOCK  CMPXCHG word ptr [I], DX

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   DX, AX
          NEG   DX

    LOCK  CMPXCHG word ptr [ECX], DX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: Int16): Int16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [I]

          MOV   DX, AX
          NEG   DX

    LOCK  CMPXCHG word ptr [I], DX

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   DX, AX
          NEG   DX

    LOCK  CMPXCHG word ptr [ECX], DX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: UInt32): UInt32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [I]

          MOV   EDX, EAX
          NEG   EDX

    LOCK  CMPXCHG dword ptr [I], EDX

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EDX, EAX
          NEG   EDX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: Int32): Int32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [I]

          MOV   EDX, EAX
          NEG   EDX

    LOCK  CMPXCHG dword ptr [I], EDX

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EDX, EAX
          NEG   EDX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedExchangeNeg(var I: UInt64): UInt64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [I]

          MOV   RDX, RAX
          NEG   RDX

    LOCK  CMPXCHG qword ptr [I], RDX

          JNZ   @TryOutStart

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: Int64): Int64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [I]

          MOV   RDX, RAX
          NEG   RDX

    LOCK  CMPXCHG qword ptr [I], RDX

          JNZ   @TryOutStart

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNeg(var I: Pointer): Pointer;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [I]

          MOV   RDX, RAX
          NEG   RDX

    LOCK  CMPXCHG qword ptr [I], RDX

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EDX, EAX
          NEG   EDX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical not
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeNot(var I: UInt8): UInt8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [I]

          MOV   DL, AL
          NOT   DL

    LOCK  CMPXCHG byte ptr [I], DL

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   DL, AL
          NOT   DL

    LOCK  CMPXCHG byte ptr [ECX], DL

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: Int8): Int8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [I]

          MOV   DL, AL
          NOT   DL

    LOCK  CMPXCHG byte ptr [I], DL

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   DL, AL
          NOT   DL

    LOCK  CMPXCHG byte ptr [ECX], DL

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: UInt16): UInt16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [I]

          MOV   DX, AX
          NOT   DX

    LOCK  CMPXCHG word ptr [I], DX

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   DX, AX
          NOT   DX

    LOCK  CMPXCHG word ptr [ECX], DX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: Int16): Int16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [I]

          MOV   DX, AX
          NOT   DX

    LOCK  CMPXCHG word ptr [I], DX

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   DX, AX
          NOT   DX

    LOCK  CMPXCHG word ptr [ECX], DX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: UInt32): UInt32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [I]

          MOV   EDX, EAX
          NOT   EDX

    LOCK  CMPXCHG dword ptr [I], EDX

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EDX, EAX
          NOT   EDX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: Int32): Int32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [I]

          MOV   EDX, EAX
          NOT   EDX

    LOCK  CMPXCHG dword ptr [I], EDX

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EDX, EAX
          NOT   EDX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedExchangeNot(var I: UInt64): UInt64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [I]

          MOV   RDX, RAX
          NOT   RDX

    LOCK  CMPXCHG qword ptr [I], RDX

          JNZ   @TryOutStart

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: Int64): Int64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [I]

          MOV   RDX, RAX
          NOT   RDX

    LOCK  CMPXCHG qword ptr [I], RDX

          JNZ   @TryOutStart

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeNot(var I: Pointer): Pointer;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [I]

          MOV   RDX, RAX
          NOT   RDX

    LOCK  CMPXCHG qword ptr [I], RDX

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EDX, EAX
          NOT   EDX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical and
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeAnd(var A: UInt8; B: UInt8): UInt8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          AND   R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          AND   BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: Int8; B: Int8): Int8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          AND   R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          AND   BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: UInt16; B: UInt16): UInt16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          AND   R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          AND   BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: Int16; B: Int16): Int16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          AND   R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          AND   BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: UInt32; B: UInt32): UInt32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          AND   R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          AND   EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: Int32; B: Int32): Int32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          AND   R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          AND   EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedExchangeAnd(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          AND   R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          AND   R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeAnd(var A: Pointer; B: Pointer): Pointer;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          AND   R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          AND   EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical or
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeOr(var A: UInt8; B: UInt8): UInt8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          OR    R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          OR    BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: Int8; B: Int8): Int8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          OR    R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          OR    BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: UInt16; B: UInt16): UInt16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          OR    R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          OR    BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: Int16; B: Int16): Int16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          OR    R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          OR    BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: UInt32; B: UInt32): UInt32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          OR    R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          OR    EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: Int32; B: Int32): Int32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          OR    R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          OR    EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedExchangeOr(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          OR    R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          OR    R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeOr(var A: Pointer; B: Pointer): Pointer;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          OR    R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          OR    EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked exchange and logical xor
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedExchangeXor(var A: UInt8; B: UInt8): UInt8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          XOR   R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          XOR   BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: Int8; B: Int8): Int8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [A]

          MOV   R8B, AL
          XOR   R8B, B

    LOCK  CMPXCHG byte ptr [A], R8B

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

          MOV   BL, AL
          XOR   BL, DL

    LOCK  CMPXCHG byte ptr [ECX], BL

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: UInt16; B: UInt16): UInt16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          XOR   R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          XOR   BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: Int16; B: Int16): Int16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [A]

          MOV   R8W, AX
          XOR   R8W, B

    LOCK  CMPXCHG word ptr [A], R8W

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

          MOV   BX, AX
          XOR   BX, DX

    LOCK  CMPXCHG word ptr [ECX], BX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: UInt32; B: UInt32): UInt32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          XOR   R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          XOR   EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: Int32; B: Int32): Int32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [A]

          MOV   R8D, EAX
          XOR   R8D, B

    LOCK  CMPXCHG dword ptr [A], R8D

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          XOR   EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedExchangeXor(var A: UInt64; B: UInt64): UInt64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          XOR   R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: Int64; B: Int64): Int64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          XOR   R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

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

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedExchangeXor(var A: Pointer; B: Pointer): Pointer;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [A]

          MOV   R8, RAX
          XOR   R8, B

    LOCK  CMPXCHG qword ptr [A], R8

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

          MOV   EBX, EAX
          XOR   EBX, EDX

    LOCK  CMPXCHG dword ptr [ECX], EBX

          JNZ   @TryOutStart

          POP   EBX

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                        Interlocked compare and exchange
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedCompareExchange(var Destination: UInt8; Exchange,Comparand: UInt8; out Exchanged: Boolean): UInt8;
asm
{$IFDEF x64}

          MOV   AL, Comparand

    LOCK  CMPXCHG byte ptr [Destination], Exchange

          SETZ  byte ptr [Exchanged]

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG byte ptr [ECX], DL

          MOV   EDX, Exchanged
          SETZ  byte ptr [EDX]

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int8; Exchange,Comparand: Int8; out Exchanged: Boolean): Int8;
asm
{$IFDEF x64}

          MOV   AL, Comparand

    LOCK  CMPXCHG byte ptr [Destination], Exchange

          SETZ  byte ptr [Exchanged]

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG byte ptr [ECX], DL

          MOV   EDX, Exchanged
          SETZ  byte ptr [EDX]

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt16; Exchange,Comparand: UInt16; out Exchanged: Boolean): UInt16;
asm
{$IFDEF x64}

          MOV   AX, Comparand

    LOCK  CMPXCHG word ptr [Destination], Exchange

          SETZ  byte ptr [Exchanged]

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG word ptr [ECX], DX

          MOV   EDX, Exchanged
          SETZ  byte ptr [EDX]

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int16; Exchange,Comparand: Int16; out Exchanged: Boolean): Int16;
asm
{$IFDEF x64}

          MOV   AX, Comparand

    LOCK  CMPXCHG word ptr [Destination], Exchange

          SETZ  byte ptr [Exchanged]

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG word ptr [ECX], DX

          MOV   EDX, Exchanged
          SETZ  byte ptr [EDX]

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt32; Exchange,Comparand: UInt32; out Exchanged: Boolean): UInt32;
asm
{$IFDEF x64}

          MOV   EAX, Comparand

    LOCK  CMPXCHG dword ptr [Destination], Exchange

          SETZ  byte ptr [Exchanged]

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          MOV   EDX, Exchanged
          SETZ  byte ptr [EDX]

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int32; Exchange,Comparand: Int32; out Exchanged: Boolean): Int32;
asm
{$IFDEF x64}

          MOV   EAX, Comparand

    LOCK  CMPXCHG dword ptr [Destination], Exchange

          SETZ  byte ptr [Exchanged]

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          MOV   EDX, Exchanged
          SETZ  byte ptr [EDX]

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedCompareExchange(var Destination: UInt64; Exchange,Comparand: UInt64; out Exchanged: Boolean): UInt64;
asm
{$IFDEF x64}

          MOV   RAX, Comparand

    LOCK  CMPXCHG qword ptr [Destination], Exchange

          SETZ  byte ptr [Exchanged]

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI
          PUSH  EDX

          MOV   EDI, EAX

          MOV   EAX, dword ptr [Comparand]
          MOV   EDX, dword ptr [Comparand + 4]

          MOV   EBX, dword ptr [Exchange]
          MOV   ECX, dword ptr [Exchange + 4]

    LOCK  CMPXCHG8B qword ptr [EDI]

          POP   ECX
          SETZ  byte ptr [ECX]

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int64; Exchange,Comparand: Int64; out Exchanged: Boolean): Int64;
asm
{$IFDEF x64}

          MOV   RAX, Comparand

    LOCK  CMPXCHG qword ptr [Destination], Exchange

          SETZ  byte ptr [Exchanged]

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI
          PUSH  EDX

          MOV   EDI, EAX

          MOV   EAX, dword ptr [Comparand]
          MOV   EDX, dword ptr [Comparand + 4]

          MOV   EBX, dword ptr [Exchange]
          MOV   ECX, dword ptr [Exchange + 4]

    LOCK  CMPXCHG8B qword ptr [EDI]

          POP   ECX
          SETZ  byte ptr [ECX]

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal128}

Function InterlockedCompareExchange(var Destination: UInt128; Exchange,Comparand: UInt128; out Exchanged: Boolean): UInt128;
asm
{$IFDEF Windows}
{
  Parameters on enter:

    RCX - pointer to a memory allocated for result
    RDX - pointer to Destination parameter
    R8  - pointer to Exchange parameter
    R9  - pointer to Comparand parameter

    Pointer to Exchanged is passed on stack.

  Result is copied into location passed in RCX and this address is also copied
  into RAX.
}
          PUSH  RBX

          MOV   R10, RCX
          MOV   R11, RDX

          MOV   RBX, qword ptr [R8]
          MOV   RCX, qword ptr [R8 + 8]

          MOV   RAX, qword ptr [R9]
          MOV   RDX, qword ptr [R9 + 8]

    LOCK  CMPXCHG16B dqword ptr [R11]

          MOV   RBX, qword ptr [Exchanged]
          SETZ  byte ptr [RBX]

          MOV   qword ptr [R10], RAX
          MOV   qword ptr [R10 + 8], RDX
          MOV   RAX, R10

          POP   RBX

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
{
  Parameters on enter:

    RDI - pointer to Destination parameter
    RSI - lower 8 bytes of Exchange parameter
    RDX - higher 8 bytes of Exchange parameter
    RCX - lower 8 bytes of Comparand parameter
    R8  - higher 8 bytes of Comparand parameter
    R9  - pointer to Exchanged parameter

  Lower 8 bytes of result are returned in RAX, higher 8 bytes in RDX.
}
          PUSH  RBX

          MOV   RBX, RSI  {Exchange.Low}
          XCHG  RCX, RDX  {Exchange.High}

          MOV   RAX, RDX  {Comparand.Low}
          MOV   RDX, R8   {Comparand.High}

    LOCK  CMPXCHG16B dqword ptr [RDI]

          SETZ  byte ptr [R9]

          POP   RBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Pointer; Exchange,Comparand: Pointer; out Exchanged: Boolean): Pointer;
asm
{$IFDEF x64}

          MOV   RAX, Comparand

    LOCK  CMPXCHG qword ptr [Destination], Exchange

          SETZ  byte ptr [Exchanged]

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG dword ptr [ECX], EDX

          MOV   EDX, Exchanged
          SETZ  byte ptr [EDX]

{$ENDIF}
end;

//------------------------------------------------------------------------------

Function InterlockedCompareExchange(var Destination: UInt8; Exchange,Comparand: UInt8): UInt8;
asm
{$IFDEF x64}

          MOV   AL, Comparand

    LOCK  CMPXCHG byte ptr [Destination], Exchange

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG byte ptr [ECX], DL

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int8; Exchange,Comparand: Int8): Int8;
asm
{$IFDEF x64}

          MOV   AL, Comparand

    LOCK  CMPXCHG byte ptr [Destination], Exchange

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG byte ptr [ECX], DL

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt16; Exchange,Comparand: UInt16): UInt16;
asm
{$IFDEF x64}

          MOV   AX, Comparand

    LOCK  CMPXCHG word ptr [Destination], Exchange

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG word ptr [ECX], DX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int16; Exchange,Comparand: Int16): Int16;
asm
{$IFDEF x64}

          MOV   AX, Comparand

    LOCK  CMPXCHG word ptr [Destination], Exchange

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG word ptr [ECX], DX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: UInt32; Exchange,Comparand: UInt32): UInt32;
asm
{$IFDEF x64}

          MOV   EAX, Comparand

    LOCK  CMPXCHG dword ptr [Destination], Exchange

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG dword ptr [ECX], EDX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int32; Exchange,Comparand: Int32): Int32;
asm
{$IFDEF x64}

          MOV   EAX, Comparand

    LOCK  CMPXCHG dword ptr [Destination], Exchange

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG dword ptr [ECX], EDX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedCompareExchange(var Destination: UInt64; Exchange,Comparand: UInt64): UInt64;
asm
{$IFDEF x64}

          MOV   RAX, Comparand

    LOCK  CMPXCHG qword ptr [Destination], Exchange

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

          MOV   EAX, dword ptr [Comparand]
          MOV   EDX, dword ptr [Comparand + 4]

          MOV   EBX, dword ptr [Exchange]
          MOV   ECX, dword ptr [Exchange + 4]

    LOCK  CMPXCHG8B qword ptr [EDI]

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Int64; Exchange,Comparand: Int64): Int64;
asm
{$IFDEF x64}

          MOV   RAX, Comparand

    LOCK  CMPXCHG qword ptr [Destination], Exchange

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

          MOV   EAX, dword ptr [Comparand]
          MOV   EDX, dword ptr [Comparand + 4]

          MOV   EBX, dword ptr [Exchange]
          MOV   ECX, dword ptr [Exchange + 4]

    LOCK  CMPXCHG8B qword ptr [EDI]

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal128}

Function InterlockedCompareExchange(var Destination: UInt128; Exchange,Comparand: UInt128): UInt128;
asm
{$IFDEF Windows}

          PUSH  RBX

          MOV   R10, RCX
          MOV   R11, RDX

          MOV   RBX, qword ptr [R8]
          MOV   RCX, qword ptr [R8 + 8]

          MOV   RAX, qword ptr [R9]
          MOV   RDX, qword ptr [R9 + 8]

    LOCK  CMPXCHG16B dqword ptr [R11]

          MOV   qword ptr [R10], RAX
          MOV   qword ptr [R10 + 8], RDX
          MOV   RAX, R10

          POP   RBX

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  RBX

          MOV   RBX, RSI  {Exchange.Low}
          XCHG  RCX, RDX  {Exchange.High}

          MOV   RAX, RDX  {Comparand.Low}
          MOV   RDX, R8   {Comparand.High}

    LOCK  CMPXCHG16B dqword ptr [RDI]

          POP   RBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedCompareExchange(var Destination: Pointer; Exchange,Comparand: Pointer): Pointer;
asm
{$IFDEF x64}

          MOV   RAX, Comparand

    LOCK  CMPXCHG qword ptr [Destination], Exchange

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XCHG  EAX, ECX

    LOCK  CMPXCHG dword ptr [ECX], EDX

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                              Interlocked bit test
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedBitTest(var I: UInt8; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          XOR   AL, AL
    LOCK  XADD  byte ptr [I], AL

          AND   Bit, 7
          BT    AX, Bit

          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XOR   CL, CL
    LOCK  XADD  byte ptr [EAX], CL

          AND   Bit, 7
          BT    CX, Bit

          SETC  AL

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTest(var I: Int8; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          XOR   AL, AL
    LOCK  XADD  byte ptr [I], AL

          AND   Bit, 7
          BT    AX, Bit

          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XOR   CL, CL
    LOCK  XADD  byte ptr [EAX], CL

          AND   Bit, 7
          BT    CX, Bit

          SETC  AL

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTest(var I: UInt16; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          XOR   AX, AX
    LOCK  XADD  word ptr [I], AX

          BT    AX, Bit

          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XOR   CX, CX
    LOCK  XADD  word ptr [EAX], CX

          BT    CX, Bit

          SETC  AL

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTest(var I: Int16; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          XOR   AX, AX
    LOCK  XADD  word ptr [I], AX

          BT    AX, Bit

          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XOR   CX, CX
    LOCK  XADD  word ptr [EAX], CX

          BT    CX, Bit

          SETC  AL

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTest(var I: UInt32; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          XOR   EAX, EAX
    LOCK  XADD  dword ptr [I], EAX

          BT    EAX, Bit

          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XOR   ECX, ECX
    LOCK  XADD  dword ptr [EAX], ECX

          BT    ECX, Bit

          SETC  AL

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTest(var I: Int32; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          XOR   EAX, EAX
    LOCK  XADD  dword ptr [I], EAX

          BT    EAX, Bit

          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XOR   ECX, ECX
    LOCK  XADD  dword ptr [EAX], ECX

          BT    ECX, Bit

          SETC  AL

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedBitTest(var I: UInt64; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          XOR   RAX, RAX
    LOCK  XADD  qword ptr [I], RAX

          BT    RAX, Bit

          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI
          PUSH  EDX   // push Bit

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          POP   ECX   // pop Bit
          CMP   ECX, 31
          CMOVA EAX, EDX

          AND   ECX, 31
          BT    EAX, ECX

          SETC  AL

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTest(var I: Int64; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          XOR   RAX, RAX
    LOCK  XADD  qword ptr [I], RAX

          BT    RAX, Bit

          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI
          PUSH  EDX

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          POP   ECX
          CMP   ECX, 31
          CMOVA EAX, EDX

          AND   ECX, 31
          BT    EAX, ECX

          SETC  AL

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTest(var I: Pointer; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          XOR   RAX, RAX
    LOCK  XADD  qword ptr [I], RAX

          AND   Bit, 63
          BT    RAX, Bit

          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XOR   ECX, ECX
    LOCK  XADD  dword ptr [EAX], ECX

          AND   Bit, 31
          BT    ECX, Bit

          SETC  AL

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                          Interlocked bit test and set
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedBitTestAndSet(var I: UInt8; Bit: Integer): Boolean;
asm
          AND   Bit, 7
    LOCK  BTS   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndSet(var I: Int8; Bit: Integer): Boolean;
asm
          AND   Bit, 7
    LOCK  BTS   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndSet(var I: UInt16; Bit: Integer): Boolean;
asm
          AND   Bit, 15
    LOCK  BTS   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndSet(var I: Int16; Bit: Integer): Boolean;
asm
          AND   Bit, 15
    LOCK  BTS   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndSet(var I: UInt32; Bit: Integer): Boolean;
asm
          AND   Bit, 31
    LOCK  BTS   dword ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndSet(var I: Int32; Bit: Integer): Boolean;
asm
          AND   Bit, 31
    LOCK  BTS   dword ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedBitTestAndSet(var I: UInt64; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          AND   Bit, 63
    LOCK  BTS   qword ptr [I], Bit
          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI
          PUSH  ESI

          MOV   EDI, EAX
          MOV   ESI, EDX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          CMP   ESI, 31
          JA    @BitTestHigh

          BTS   EBX, ESI
          JMP   @BitTestEnd

    @BitTestHigh:

          BTS   ECX, ESI

    @BitTestEnd:

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          SETC  AL

          POP   ESI
          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndSet(var I: Int64; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          AND   Bit, 63
    LOCK  BTS   qword ptr [I], Bit
          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI
          PUSH  ESI

          MOV   EDI, EAX
          MOV   ESI, EDX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          CMP   ESI, 31
          JA    @BitTestHigh

          BTS   EBX, ESI
          JMP   @BitTestEnd

    @BitTestHigh:

          BTS   ECX, ESI

    @BitTestEnd:

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          SETC  AL

          POP   ESI
          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndSet(var I: Pointer; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          AND   Bit, 63
    LOCK  BTS   qword ptr [I], Bit
          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          AND   Bit, 31
    LOCK  BTS   dword ptr [I], Bit
          SETC  AL

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                         Interlocked bit test and reset
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedBitTestAndReset(var I: UInt8; Bit: Integer): Boolean;
asm
          AND   Bit, 7
    LOCK  BTR   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndReset(var I: Int8; Bit: Integer): Boolean;
asm
          AND   Bit, 7
    LOCK  BTR   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndReset(var I: UInt16; Bit: Integer): Boolean;
asm
          AND   Bit, 15
    LOCK  BTR   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndReset(var I: Int16; Bit: Integer): Boolean;
asm
          AND   Bit, 15
    LOCK  BTR   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndReset(var I: UInt32; Bit: Integer): Boolean;
asm
          AND   Bit, 31
    LOCK  BTR   dword ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndReset(var I: Int32; Bit: Integer): Boolean;
asm
          AND   Bit, 31
    LOCK  BTR   dword ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedBitTestAndReset(var I: UInt64; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          AND   Bit, 63
    LOCK  BTR   qword ptr [I], Bit
          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI
          PUSH  ESI

          MOV   EDI, EAX
          MOV   ESI, EDX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          CMP   ESI, 31
          JA    @BitTestHigh

          BTR   EBX, ESI
          JMP   @BitTestEnd

    @BitTestHigh:

          BTR   ECX, ESI

    @BitTestEnd:

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          SETC  AL

          POP   ESI
          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndReset(var I: Int64; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          AND   Bit, 63
    LOCK  BTR   qword ptr [I], Bit
          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI
          PUSH  ESI

          MOV   EDI, EAX
          MOV   ESI, EDX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          CMP   ESI, 31
          JA    @BitTestHigh

          BTR   EBX, ESI
          JMP   @BitTestEnd

    @BitTestHigh:

          BTR   ECX, ESI

    @BitTestEnd:

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          SETC  AL

          POP   ESI
          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndReset(var I: Pointer; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          AND   Bit, 63
    LOCK  BTR   qword ptr [I], Bit
          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          AND   Bit, 31
    LOCK  BTR   dword ptr [I], Bit
          SETC  AL

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                      Interlocked bit test and complement
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedBitTestAndComplement(var I: UInt8; Bit: Integer): Boolean;
asm
          AND   Bit, 7
    LOCK  BTC   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndComplement(var I: Int8; Bit: Integer): Boolean;
asm
          AND   Bit, 7
    LOCK  BTC   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndComplement(var I: UInt16; Bit: Integer): Boolean;
asm
          AND   Bit, 15
    LOCK  BTC   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndComplement(var I: Int16; Bit: Integer): Boolean;
asm
          AND   Bit, 15
    LOCK  BTC   word ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndComplement(var I: UInt32; Bit: Integer): Boolean;
asm
          AND   Bit, 31
    LOCK  BTC   dword ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndComplement(var I: Int32; Bit: Integer): Boolean;
asm
          AND   Bit, 31
    LOCK  BTC   dword ptr [I], Bit
          SETC  AL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedBitTestAndComplement(var I: UInt64; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          AND   Bit, 63
    LOCK  BTC   qword ptr [I], Bit
          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI
          PUSH  ESI

          MOV   EDI, EAX
          MOV   ESI, EDX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          CMP   ESI, 31
          JA    @BitTestHigh

          BTC   EBX, ESI
          JMP   @BitTestEnd

    @BitTestHigh:

          BTC   ECX, ESI

    @BitTestEnd:

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          SETC  AL

          POP   ESI
          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndComplement(var I: Int64; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          AND   Bit, 63
    LOCK  BTC   qword ptr [I], Bit
          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI
          PUSH  ESI

          MOV   EDI, EAX
          MOV   ESI, EDX

    @TryOutStart:

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]

          MOV   EBX, EAX
          MOV   ECX, EDX

          CMP   ESI, 31
          JA    @BitTestHigh

          BTC   EBX, ESI
          JMP   @BitTestEnd

    @BitTestHigh:

          BTC   ECX, ESI

    @BitTestEnd:

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          SETC  AL

          POP   ESI
          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedBitTestAndComplement(var I: Pointer; Bit: Integer): Boolean;
asm
{$IFDEF x64}

          AND   Bit, 63
    LOCK  BTC   qword ptr [I], Bit
          SETC  AL

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          AND   Bit, 31
    LOCK  BTC   dword ptr [I], Bit
          SETC  AL

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                                Interlocked load
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedLoad(var I: UInt8): UInt8;
asm
          XOR   DL, DL
    LOCK  XADD  byte ptr [I], DL
          MOV   AL, DL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: Int8): Int8;
asm
          XOR   DL, DL
    LOCK  XADD  byte ptr [I], DL
          MOV   AL, DL
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: UInt16): UInt16;
asm
          XOR   DX, DX
    LOCK  XADD  word ptr [I], DX
          MOV   AX, DX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: Int16): Int16;
asm
          XOR   DX, DX
    LOCK  XADD  word ptr [I], DX
          MOV   AX, DX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: UInt32): UInt32;
asm
          XOR   EDX, EDX
    LOCK  XADD  dword ptr [I], EDX
          MOV   EAX, EDX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: Int32): Int32;
asm
          XOR   EDX, EDX
    LOCK  XADD  dword ptr [I], EDX
          MOV   EAX, EDX
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedLoad(var I: UInt64): UInt64;
asm
{$IFDEF x64}

          XOR   RDX, RDX
    LOCK  XADD  qword ptr [I], RDX
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

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: Int64): Int64;
asm
{$IFDEF x64}

          XOR   RDX, RDX
    LOCK  XADD  qword ptr [I], RDX
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

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedLoad(var I: Pointer): Pointer;
asm
{$IFDEF x64}

          XOR   RDX, RDX
    LOCK  XADD  qword ptr [I], RDX
          MOV   RAX, RDX

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          XOR   EDX, EDX
    LOCK  XADD  dword ptr [I], EDX
          MOV   EAX, EDX

{$ENDIF}
end;


{===============================================================================
--------------------------------------------------------------------------------
                               Interlocked store                                                               
--------------------------------------------------------------------------------
===============================================================================}

Function InterlockedStore(var I: UInt8; NewValue: UInt8): UInt8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [I]

    LOCK  CMPXCHG byte ptr [I], NewValue

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

    LOCK  CMPXCHG byte ptr [ECX], DL

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: Int8; NewValue: Int8): Int8;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AL, byte ptr [I]

    LOCK  CMPXCHG byte ptr [I], NewValue

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AL, byte ptr [ECX]

    LOCK  CMPXCHG byte ptr [ECX], DL

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: UInt16; NewValue: UInt16): UInt16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [I]

    LOCK  CMPXCHG word ptr [I], NewValue

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

    LOCK  CMPXCHG word ptr [ECX], DX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: Int16; NewValue: Int16): Int16;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   AX, word ptr [I]

    LOCK  CMPXCHG word ptr [I], NewValue

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   AX, word ptr [ECX]

    LOCK  CMPXCHG word ptr [ECX], DX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: UInt32; NewValue: UInt32): UInt32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [I]

    LOCK  CMPXCHG dword ptr [I], NewValue

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: Int32; NewValue: Int32): Int32;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   EAX, dword ptr [I]

    LOCK  CMPXCHG dword ptr [I], NewValue

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFDEF IncludeVal64}

Function InterlockedStore(var I: UInt64; NewValue: UInt64): UInt64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [I]

    LOCK  CMPXCHG qword ptr [I], NewValue

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EBX, dword ptr [NewValue]
          MOV   ECX, dword ptr [NewValue + 4]

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]          

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          POP   EDI
          POP   EBX

{$ENDIF}
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: Int64; NewValue: Int64): Int64;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [I]

    LOCK  CMPXCHG qword ptr [I], NewValue

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          PUSH  EBX
          PUSH  EDI

          MOV   EDI, EAX

    @TryOutStart:

          MOV   EBX, dword ptr [NewValue]
          MOV   ECX, dword ptr [NewValue + 4]

          MOV   EAX, dword ptr [EDI]
          MOV   EDX, dword ptr [EDI + 4]          

    LOCK  CMPXCHG8B qword ptr [EDI]

          JNZ   @TryOutStart

          POP   EDI
          POP   EBX

{$ENDIF}
end;

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function InterlockedStore(var I: Pointer; NewValue: Pointer): Pointer;
asm
{$IFDEF x64}

    @TryOutStart:

          MOV   RAX, qword ptr [I]

    LOCK  CMPXCHG qword ptr [I], NewValue

          JNZ   @TryOutStart

{$ELSE}// -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

          MOV   ECX, EAX

    @TryOutStart:

          MOV   EAX, dword ptr [ECX]

    LOCK  CMPXCHG dword ptr [ECX], EDX

          JNZ   @TryOutStart

{$ENDIF}
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
{$IF Defined(IncludeVal64) and not Defined(x64)}
  If not Info.ProcessorFeatures.CX8 then
    raise EILOUnsupportedInstruction.Create('Instruction CMPXCHG8B is not supported by the CPU.');
  If not Info.ProcessorFeatures.CMOV then
    raise EILOUnsupportedInstruction.Create('Instruction CMOVcc is not supported by the CPU.');
{$IFEND}
{$IFDEF IncludeVal128}
  If not Info.ProcessorFeatures.CMPXCHG16B then
    raise EILOUnsupportedInstruction.Create('Instruction CMPXCHG16B is not supported by the CPU.');
{$ENDIF}
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

initialization
  Initialize;

end.

