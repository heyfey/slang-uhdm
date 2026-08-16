// r10uvm74 arm b4 — the INDEX KINDS THAT MIGHT FOLD TO A CONSTANT, which is
// the one way this law's `emitExpr`-emitted index could acquire a `vpiParent`
// golden does not want (golden's index CONSTANTS are UNPARENTED, arm b1 cells
// k_lit/k_lit0).  The corpus population contains none of these — its 55 cells
// index by a local variable, a formal, or an integer literal — so this arm
// exists to say what golden does, and to make the claim "no folded-constant
// index reaches this builder in either corpus" a MEASUREMENT and not a hope.
package p4;
  localparam int PK = 2;
  typedef enum int { E0 = 0, E1 = 1 } e_t;
endpackage

module b4;
  import p4::*;

  localparam int MK = 1;

  class user;
    string sq[$];
    int    r;

    function void f();
      r = sq[p4::PK].len();   // f_pkgqual  — PACKAGE localparam, qualified
      r = sq[PK].len();       // f_pkgbare  — PACKAGE localparam, wildcard-imported
      r = sq[MK].len();       // f_modparam — MODULE localparam
      r = sq[E1].len();       // f_enumconst— an ENUM CONSTANT
      r = sq[1 + 1].len();    // f_constexpr— a FOLDABLE expression
    endfunction
  endclass

  user u;
  initial begin
    u = new();
    u.f();
  end
endmodule
