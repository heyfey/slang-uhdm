// v209 verifier arm I — OUT-OF-BODY NON-CONSTRUCTOR BODIES.  A task and a
// function defined out of body carry locals of exactly the shapes the
// constructor hoists; golden must list NONE of them in the package (§ 203's
// measured distinguisher).  A second class has BOTH an out-of-body `new` and
// an out-of-body task, so the two walks meet in one package.
package pi209;
  class ci209a;
    int n;
  endclass
  class ci209b;
    int q;
    extern task ti209(input int a);
    extern function int fi209(input int a);
  endclass
  task ci209b::ti209(input int a);
    ci209a lt_h;
    int     lt_i;
    static  int lt_s;
    lt_h = null;
    lt_i = a;
    lt_s = a;
  endtask
  function int ci209b::fi209(input int a);
    ci209a lf_h;
    int     lf_i;
    lf_h = null;
    lf_i = a;
    return lf_i;
  endfunction
  class ci209c;
    int r;
    extern function new();
    extern task tc209();
  endclass
  function ci209c::new();
    ci209a lc_h;
    int    lc_i;
    lc_h = null;
    r = 3;
  endfunction
  task ci209c::tc209();
    ci209a lz_h;
    lz_h = null;
  endtask
endpackage

import pi209::*;

module gi209;
  initial $display("i");
endmodule
