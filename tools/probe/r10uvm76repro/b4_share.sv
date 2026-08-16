// r10uvm76 arm b4 — ONE WIRE PER NAME, minted at the FIRST reference, shared
// by every later out-of-body method; plus the two contexts that must mint
// nothing even though the name is in scope.
// Cells: f1 E_A   FIRST reference           -> mints the wire, at THIS span
//        f2 E_A   later, DIFFERENT method   -> the SAME wire
//        f2 E_B   first E_B reference       -> its own wire, at THIS span
//        init E_A a class PROPERTY INITIALIZER (no subroutine at all)
//                 -> golden mints nothing (SimpleUVM: uvm_reg_sequence's
//                    `seq_parent_e parent_select = LOCAL;` @158:32 is bare)
package p76d;
  class c76;
    typedef enum {E_A, E_B, E_C} e76_t;
    e76_t m = E_A;                    // init: property initializer
    extern function int f1(int k);
    extern function int f2(int k);
  endclass
  function int c76::f1(int k);
    int r;
    r = (m == E_A) ? 1 : 0;           // FIRST E_A reference -> mint here
    return r + k;
  endfunction
  function int c76::f2(int k);
    int r;
    r = (m == E_B) ? 2 : 0;           // FIRST E_B reference -> mint here
    if (m == E_A) r = r + 4;          // SHARES f1's wire
    return r + k;
  endfunction
endpackage
import p76d::*;
module top76d;
  c76 c;
  int r;
  initial begin
    c = new();
    r = c.f1(1) + c.f2(2);
  end
endmodule
