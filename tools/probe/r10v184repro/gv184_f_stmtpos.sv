// r10v184 VERIFIER ARM F — STATEMENT POSITION vs EXPRESSION POSITION for a
// built-in STRING method call in a WILDCARD-IMPORT CLONE.
//
// Arm D found that golden binds `warp.putc(gauge, pip)`'s arguments to their
// OWN declarations, not to the receiver — the opposite of every expression-
// position cell — and that the patch does not fire there.  In arm D the two
// candidate causes are CONFOUNDED: `putc` is void, so it can only appear as a
// STATEMENT.  This arm separates them as far as SystemVerilog allows:
//   * every VOID string method in statement position (putc / itoa / bintoa /
//     hextoa / octtoa / realtoa) — void methods are statement-only
//   * the SAME non-void method in EXPRESSION position and inside a `void'()`
//     CAST at statement level, which is expression position wearing a
//     statement's clothes
//   * the same call as a CONDITION, as a `case` selector and as an actual
//     argument of another call
// If the patch fired anywhere golden does not, this arm reads AWAY.
// Names, numbers and orders are deliberately unlike the corpus'.
package Mortise405;

  function automatic string tenon405(input int fml_m);
    string  batten;
    string  keeper;
    int     dowel;
    byte    peg;
    real    shim;
    batten = "battenboard";
    dowel  = 3;
    peg    = 8'h42;
    shim   = 2.5;

    // ---- VOID string methods, statement position ----
    batten.putc(dowel, peg);              // F1  void, 2 name args
    batten.itoa(dowel);                   // F2  void, 1 name arg
    batten.bintoa(dowel);                 // F3  void, 1 name arg
    batten.hextoa(dowel);                 // F4  void, 1 name arg
    batten.octtoa(dowel);                 // F5  void, 1 name arg
    batten.realtoa(shim);                 // F6  void, 1 name arg (real)

    // ---- the SAME shape in EXPRESSION position ----
    keeper = batten.substr(1, dowel);     // F7  plain expression
    dowel  = batten.getc(dowel);          // F8  plain expression
    void'(batten.getc(dowel));            // F9  void CAST at statement level
    if (batten.getc(dowel) != 0)          // F10 a CONDITION
      keeper = "hit";
    case (batten.getc(dowel))             // F11 a case SELECTOR
      0: keeper = "zero";
      default: keeper = "other";
    endcase
    keeper = $sformatf("%s", batten.substr(1, fml_m)); // F12 actual of a syscall
    return keeper;
  endfunction

endpackage

// WILDCARD import — the clone path the law owns.
package Rebate405;
  import Mortise405::*;
  int seen_rebate405 = 31;
  function automatic int use_rebate405();
    return tenon405(7).len();
  endfunction
endpackage

module top405f;
  import Rebate405::*;
  int tally405f;
  initial begin
    tally405f = use_rebate405();
    $display("%0d", tally405f);
  end
endmodule
