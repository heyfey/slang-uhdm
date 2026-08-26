// r10uvm157 grid, arm B — THE TARGET-TYPE AXIS.  ONE typedef per `begin`, so
// every form is scored on its OWN cell and a form this law declines cannot
// hide (or take down) the forms it claims.  The same set is written twice —
// once inside a PACKAGE FREE FUNCTION and once inside a MODULE `initial` —
// with different names, a different case convention and different widths, so
// no cell can agree with its twin by accident.  MEASUREMENT ONLY.
package Ledger157;
  parameter int QUILL157 = 6;
  typedef bit [1:0] ledgerPairPkg157;     // the alias target, a PACKAGE typedef
  class Scribe157;
    int nib;
  endclass

  function void tally();
    begin  // b01  a bit vector with a CONSTANT range
      typedef bit [4:0] tallyFive157;
      tallyFive157 useFive; useFive = 0;
    end
    begin  // b02  a bit vector whose range is a $bits() EXPRESSION (the head)
      typedef bit [$bits(ledgerPairPkg157)-1:0] tallyBitsExpr157;
      tallyBitsExpr157 useBitsExpr; useBitsExpr = 0;
    end
    begin  // b03  a bit vector whose range is a PARAMETER expression
      typedef bit [QUILL157-1:0] tallyParamRange157;
      tallyParamRange157 useParamRange; useParamRange = 0;
    end
    begin  // b04  a BARE bit (no range at all)
      typedef bit tallyBareBit157;
      tallyBareBit157 useBareBit; useBareBit = 0;
    end
    begin  // b05  logic with a range
      typedef logic [3:0] tallyLogicNib157;
      tallyLogicNib157 useLogicNib; useLogicNib = 0;
    end
    begin  // b06  a SIGNED vector
      typedef bit signed [7:0] tallySignedByte157;
      tallySignedByte157 useSignedByte; useSignedByte = 0;
    end
    begin  // b07  a bare int
      typedef int tallyPlainInt157;
      tallyPlainInt157 usePlainInt; usePlainInt = 0;
    end
    begin  // b08  int unsigned
      typedef int unsigned tallyUintAtom157;
      tallyUintAtom157 useUintAtom; useUintAtom = 0;
    end
    begin  // b09  byte
      typedef byte tallyByteAtom157;
      tallyByteAtom157 useByteAtom; useByteAtom = 0;
    end
    begin  // b10  shortint
      typedef shortint tallyShortAtom157;
      tallyShortAtom157 useShortAtom; useShortAtom = 0;
    end
    begin  // b11  longint
      typedef longint tallyLongAtom157;
      tallyLongAtom157 useLongAtom; useLongAtom = 0;
    end
    begin  // b12  integer
      typedef integer tallyIntegerAtom157;
      tallyIntegerAtom157 useIntegerAtom; useIntegerAtom = 0;
    end
    begin  // b13  time
      typedef time tallyTimeAtom157;
      tallyTimeAtom157 useTimeAtom; useTimeAtom = 0;
    end
    begin  // b14  string
      typedef string tallyStringAtom157;
      tallyStringAtom157 useStringAtom; useStringAtom = "";
    end
    begin  // b15  real
      typedef real tallyRealAtom157;
      tallyRealAtom157 useRealAtom; useRealAtom = 0.0;
    end
    begin  // b16  shortreal
      typedef shortreal tallyShortRealAtom157;
      tallyShortRealAtom157 useShortRealAtom; useShortRealAtom = 0.0;
    end
    begin  // b17  chandle
      typedef chandle tallyHandleAtom157;
      tallyHandleAtom157 useHandleAtom; useHandleAtom = null;
    end
    begin  // b18  an inline ENUM
      typedef enum { TALLY_RED, TALLY_BLUE } tallyHueEnum157;
      tallyHueEnum157 useHueEnum; useHueEnum = TALLY_RED;
    end
    begin  // b19  an inline enum with a BASE type
      typedef enum bit [1:0] { TALLY_LOW = 2'd0, TALLY_HIGH = 2'd3 } tallyBaseEnum157;
      tallyBaseEnum157 useBaseEnum; useBaseEnum = TALLY_LOW;
    end
    begin  // b20  a PACKED struct
      typedef struct packed { bit carry; bit spare; } tallyPackedRec157;
      tallyPackedRec157 usePackedRec; usePackedRec = 0;
    end
    begin  // b21  an UNPACKED struct
      typedef struct { int folio; byte mark; } tallyLooseRec157;
      tallyLooseRec157 useLooseRec; useLooseRec.folio = 0;
    end
    begin  // b22  a packed UNION
      typedef union packed { bit [1:0] duo; bit [1:0] pair; } tallyUnion157;
      tallyUnion157 useUnion; useUnion = 0;
    end
    begin  // b23  a BARE NAME target — another typedef (the DummyType arm)
      typedef ledgerPairPkg157 tallyAliasOfPkg157;
      tallyAliasOfPkg157 useAliasOfPkg; useAliasOfPkg = 0;
    end
    begin  // b24  a BARE NAME target — a CLASS
      typedef Scribe157 tallyAliasOfCls157;
      tallyAliasOfCls157 useAliasOfCls; useAliasOfCls = null;
    end
    begin  // b25  a SCOPED name target
      typedef Ledger157::ledgerPairPkg157 tallyScopedAlias157;
      tallyScopedAlias157 useScopedAlias; useScopedAlias = 0;
    end
    begin  // b26  an UNPACKED ARRAY of an atom
      typedef int tallyIntQuad157 [4];
      tallyIntQuad157 useIntQuad; useIntQuad[0] = 0;
    end
    begin  // b27  an UNPACKED ARRAY of a vector
      typedef bit [7:0] tallyByteTrio157 [3];
      tallyByteTrio157 useByteTrio; useByteTrio[0] = 0;
    end
    begin  // b28  a QUEUE
      typedef int tallyIntQueue157 [$];
      tallyIntQueue157 useIntQueue; useIntQueue.delete();
    end
    begin  // b29  a DYNAMIC array
      typedef int tallyIntDyn157 [];
      tallyIntDyn157 useIntDyn; useIntDyn = new[2];
    end
    begin  // b30  an ASSOCIATIVE array
      typedef int tallyIntAssoc157 [string];
      tallyIntAssoc157 useIntAssoc; useIntAssoc["a"] = 0;
    end
    begin  // b31  a typedef with NO USER AT ALL in the whole design
      typedef bit [30:0] tallyOrphan157;
      int useOrphanNeighbour; useOrphanNeighbour = 0;
    end
    begin  // b32  TWO listable typedefs and one NAME target, interleaved with
           //      variables — the ORDER and the SKIP in one cell
      typedef bit [23:0] tallyTrioFirst157;
      tallyTrioFirst157 useTrioA;
      typedef ledgerPairPkg157 tallyTrioSkip157;
      tallyTrioSkip157 useTrioB;
      typedef logic [5:0] tallyTrioLast157;
      tallyTrioLast157 useTrioC;
      useTrioA = 0; useTrioB = 0; useTrioC = 0;
    end
    begin  // b33  a listable typedef AND a DECLINED one in the same scope —
           //      the whole cell must stay exactly as it is today
      typedef bit [12:0] tallyMixedVec157;
      typedef enum { TALLY_MIX_A, TALLY_MIX_B } tallyMixedEnum157;
      tallyMixedVec157  useMixedVec;
      tallyMixedEnum157 useMixedEnum;
      useMixedVec = 0; useMixedEnum = TALLY_MIX_A;
    end
  endfunction
endpackage

module Quire157;
  parameter int MARGIN157 = 5;
  typedef bit [2:0] quireTriModule157;
  initial begin
    begin typedef bit [9:0] QUIRE_TEN;  QUIRE_TEN qTen; qTen = 0; end
    begin typedef bit [$bits(quireTriModule157)+1:0] QUIRE_BITS_EXPR;
          QUIRE_BITS_EXPR qBitsExpr; qBitsExpr = 0; end
    begin typedef bit [MARGIN157-1:0] QUIRE_PARAM_RANGE;
          QUIRE_PARAM_RANGE qParamRange; qParamRange = 0; end
    begin typedef logic [6:0] QUIRE_LOGIC_SEVEN;
          QUIRE_LOGIC_SEVEN qLogicSeven; qLogicSeven = 0; end
    begin typedef shortint QUIRE_SHORTINT; QUIRE_SHORTINT qShortint; qShortint = 0; end
    begin typedef enum { QUIRE_UP, QUIRE_DOWN } QUIRE_DIR;
          QUIRE_DIR qDir; qDir = QUIRE_UP; end
    begin typedef struct packed { bit [3:0] head; bit tailbit; } QUIRE_REC;
          QUIRE_REC qRec; qRec = 0; end
    begin typedef quireTriModule157 QUIRE_ALIAS; QUIRE_ALIAS qAlias; qAlias = 0; end
    begin typedef byte QUIRE_BYTE_PAIR [2]; QUIRE_BYTE_PAIR qBytePair; qBytePair[0] = 0; end
  end
endmodule
