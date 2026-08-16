// r10uvm76 arm b3 — THE OVER-FIRE GUARD.  The very same class-scope enum
// constants, read from the very same OUT-OF-BODY method, but written
// QUALIFIED (`c76::E_A`).  A `::`-scoped name carries its own scope, Surelog
// resolves it, and golden mints NO wire.
//
// This is not a hypothetical: SimpleUVM has 24 such references
// (`process::KILLED`, `process::FINISHED`, `uvm_mem_mam::GREEDY/BROAD`,
// `uvm_resource_types::PRI_HIGH/PRI_LOW/NAME_OVERRIDE/TYPE_OVERRIDE`), every
// one of them a class-scope enum constant inside an out-of-body method, and
// every one of them bare in golden.  A law written without the
// unqualified test would have minted a wire for all 24.
package p76c;
  class c76;
    typedef enum {E_A, E_B, E_C} e76_t;
    e76_t m;
    extern function int oobf(int k);
  endclass
  class d76;
    typedef enum {F_A, F_B} f76_t;
  endclass
  function int c76::oobf(int k);
    int r;
    r = 0;
    if (m == c76::E_A) r = r + 1;     // qualified, OWN class
    if (m == c76::E_B) r = r + 2;     // qualified, OWN class
    if (k == int'(d76::F_A)) r = r + 4;   // qualified, ANOTHER class
    return r;
  endfunction
endpackage
import p76c::*;
module top76c;
  c76 c;
  int r;
  initial begin
    c = new();
    r = c.oobf(1);
  end
endmodule
