// r10earl5 jj.sv — THE pwrmgr ROOT, isolated.
// r10earl5op on the corpus says pwrmgr_pkg row 12 (PWR_PERI_DEFAULT,
// pwrmgr_pkg.sv:155) is the ONE unequal row of that package; typespec::Compare
// recurses Instance(), so every one of the package's 16 typespecs and every
// pattern row 5..12 reports it as their head, and rstmgr_pkg/alert_pkg/
// flash_*_pkg inherit it through their own reads.
//
// GOLDEN row 12 (TOP listing):
//   operation op75  ts -> struct_typespec pwr_peri_t   (PARENTLESS ref)
//     constant {ct=9 sz=16 dec=''  val=UINT:1}      <- WakeUpPeris'(1'b1)
//     constant {ct=9 sz=2  dec='0' val=UINT:0}      <- '0
// OURS:
//   operation op75  ts <null>
//     tagged_pattern 'wakeups' -> operation op67 (the cast, unfolded)
//     tagged_pattern 'rstreqs' -> constant {ct=3 sz=-1 dec=''0'}
//
// Rows 5..11 (plain sized literals per member) ALREADY flatten to untagged
// member constants on both sides — so the trigger is a member value that our
// fold does not reduce, not the pattern shape.
package jp;

  parameter HwRstReqs = 2;
  localparam WakeUpPeris = 16;

  typedef struct packed {
    logic [WakeUpPeris-1:0] wakeups;
    logic [HwRstReqs-1:0]   rstreqs;
  } pwr_peri_t;

  // row 0 — THE pwrmgr shape: a SIZE CAST member and an UNSIZED FILL member
  parameter pwr_peri_t PERI_DEFAULT = '{
    wakeups: WakeUpPeris'(1'b1),
    rstreqs: '0
  };

  // row 1 — control: both members plain sized literals (rows 5..11's shape)
  parameter pwr_peri_t PERI_LIT = '{
    wakeups: 16'h1,
    rstreqs: 2'b10
  };

  // row 2 — only the unsized fill
  parameter pwr_peri_t PERI_FILL = '{
    wakeups: '1,
    rstreqs: '0
  };

  // row 3 — only the size cast
  parameter pwr_peri_t PERI_CAST = '{
    wakeups: WakeUpPeris'(1'b1),
    rstreqs: 2'b01
  };

  // row 4 — a cast written with a LITERAL size instead of a parameter
  parameter pwr_peri_t PERI_CASTLIT = '{
    wakeups: 16'(1'b1),
    rstreqs: 2'b11
  };

  // (a TYPE cast `int'(1'b1)` was measured here too — golden folds it to
  // UINT:1 at SIZE 64 with no decompile in the DEF view, where our existing
  // type-cast arm (ExprEmit, § FuncStructValSimple `bit'(x)`) writes BIN at
  // the MEMBER width.  MEASURED, NOT IMPLEMENTED, 0 corpus tests — the ready
  // witness is kk.sv, kept out of this one so jj stays a clean positive.)

  // (the PARENTHESIZED form `(WakeUpPeris)'(1'b1)` was measured here too and
  // gives the same EMPTY decompile — but it also drags in
  // § isParenCastWidthParam, which stamps vpiInstance onto WakeUpPeris' OWN
  // int_typespec and makes every row of this package unequal for an unrelated
  // reason.  Kept out of the witness on purpose.)

  // row 6 — a size cast NARROWER than the member: separates "the CAST's width"
  // from "the MEMBER's width" in the folded constant's VpiSize
  parameter pwr_peri_t PERI_NCAST = '{
    wakeups: 8'(1'b1),
    rstreqs: 2'b01
  };

  // row 7 — a size cast over a SIZED BASED literal: separates "the operand is
  // a based literal" from "the value is wider than 64 bits" as the reason
  // ImportedDoubleCastedParameter's `96'(96'h 4c52...)` is NOT folded
  parameter pwr_peri_t PERI_BCAST = '{
    wakeups: 16'(16'h1),
    rstreqs: 2'b01
  };

  // row 8 — a size cast over a NON-literal operand
  parameter pwr_peri_t PERI_RCAST = '{
    wakeups: WakeUpPeris'(HwRstReqs),
    rstreqs: 2'b01
  };

endpackage

// Every row is read by a DIRECT cont-assign naming it with its `jp::`
// QUALIFIER — the exact shape the SCOPED-REFERENCE rule (ParamEmit ~8710) was
// measured on, and the shape top_earlgrey.sv uses.  The rows then differ ONLY
// in their member VALUE forms.
module jchild (input logic clk_i, output logic o);
  jp::pwr_peri_t r0, r1, r2, r3, r4, r6, r7, r8;
  assign r0 = jp::PERI_DEFAULT;
  assign r1 = jp::PERI_LIT;
  assign r2 = jp::PERI_FILL;
  assign r3 = jp::PERI_CAST;
  assign r4 = jp::PERI_CASTLIT;
  assign r6 = jp::PERI_NCAST;
  assign r7 = jp::PERI_BCAST;
  assign r8 = jp::PERI_RCAST;
  assign o = r0.rstreqs[0] ^ r1.rstreqs[0] ^ r2.rstreqs[0] ^
             r3.rstreqs[0] ^ r4.rstreqs[0] ^
             r6.rstreqs[0] ^ r7.rstreqs[0] ^ r8.rstreqs[0] ^ clk_i;
endmodule

module jj (input logic clk_i, output logic o);
  jchild u_j (.clk_i(clk_i), .o(o));
endmodule
