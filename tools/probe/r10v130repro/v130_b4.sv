// r10v130repro/v130_b4.sv — VERIFIER ARM b4: MULTIPLICITY and IMPORT SHAPE.
// One package, one out-of-body method reading ONE name in a new[...] size
// argument; TWO tops, a child instantiated THREE times, and a fourth module
// that imports NOTHING.  Golden mints one wire in the FIRST module written that
// cannot bind the name; the question is where WE mint.
// MEASUREMENT ONLY.  LHS is ALWAYS golden; RHS is ALWAYS ours.
package pkMult130v;
  class cMult130v;
    int dynMult130v[];
    extern function void multRunner130v();
  endclass
  function void cMult130v::multRunner130v();
    int spreadOmi130v;
    spreadOmi130v = 4;
    dynMult130v = new[spreadOmi130v];
  endfunction
endpackage

import pkMult130v::*;

module kidMult130v;
  initial begin
    cMult130v hKid130v;
    hKid130v = new();
    hKid130v.multRunner130v();
  end
endmodule

module topAmult130v;
  kidMult130v i0mult130v();
  kidMult130v i1mult130v();
  kidMult130v i2mult130v();
endmodule

module topBmult130v;
  kidMult130v j0mult130v();
endmodule

module noImportMult130v;
  int untouchedPii130v;
  initial untouchedPii130v = 0;
endmodule
