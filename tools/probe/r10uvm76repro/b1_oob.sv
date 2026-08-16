// r10uvm76 arm b1 — the POSITIVE arm.  A CLASS-SCOPE enum constant read
// UNQUALIFIED from an OUT-OF-BODY method, in a package a module hoists.
// Cells: e_first  the FIRST unqualified read of E_A   -> mints work@top76a.E_A
//        e_again  a LATER read of E_A                 -> SHARES that wire
//        e_other  an unqualified read of E_B          -> mints its own wire
//        e_never  E_C is declared and NEVER read      -> no wire at all
package p76a;
  typedef enum {G_X, G_Y} g76_t;      // PACKAGE-scope enum: resolves, no wire
  class c76;
    typedef enum {E_A, E_B, E_C} e76_t;
    e76_t m;
    extern function int oobf(int k);
  endclass
  // OUT-OF-BODY definition: compiled in p76a's scope, where E_A/E_B are as
  // invisible as a class property.
  function int c76::oobf(int k);
    int r;
    r = 0;
    if (m == E_A) r = r + 1;          // e_first
    if (m == E_B) r = r + 2;          // e_other
    if (m == E_A) r = r + 4;          // e_again (same wire as e_first)
    if (k == G_X) r = r + 8;          // package-scope: enum_const, NOT a wire
    return r;
  endfunction
endpackage
import p76a::*;
module top76a;
  c76 c;
  int r;
  initial begin
    c = new();
    r = c.oobf(1);
  end
endmodule
