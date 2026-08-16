// r10uvm76 VERIFIER arm — the module half.  b1's package, compiled but never
// IMPORTED, so nothing hoists the class body and there is no module to mint
// into.  Golden nets nothing; a build that mints here has moved the law's
// gate from "a module that hoists the package" to "any out-of-body method"
// and would fire on Scoreboard and BuildUVMPkg, which compile uvm_pkg and
// hoist none of it.
package p76e;
  class c76;
    typedef enum {E_A, E_B, E_C} e76_t;
    e76_t m;
    extern function int oobf(int k);
  endclass
  function int c76::oobf(int k);
    int r;
    r = 0;
    if (m == E_A) r = r + 1;
    if (m == E_B) r = r + 2;
    return r + k;
  endfunction
endpackage
module top76e;                 // NO import of p76e
  int r;
  initial r = 0;
endmodule
