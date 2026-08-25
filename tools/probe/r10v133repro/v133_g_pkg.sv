// r10v133 arm G - the PACKAGE def listing vs the top copy, and an out-of-block
// class method, over calls.  MEASUREMENT ONLY.
package pv133g;
  function automatic int gf133(); return 5; endfunction
  int    gq[$];
  int    gr1 = $bits(gf133());        // G01 package-level init over a call
  localparam int GL133 = $bits(gf133()); // G02 package localparam over a call

  class oob133_c;
    int oq[$];
    extern function void oobm133();
    function int of133(); return 3; endfunction
  endclass

  function void oob133_c::oobm133();  // G03 OUT OF BLOCK method body
    int r;
    r = $bits(of133());
    r = $bits(oq.size());
    r = $bits(this.oq.size());
    if (r == 0) r = 1;
  endfunction
endpackage

module vm133g;
  import pv133g::*;
  int r;
  initial r = $bits(gf133()) + GL133;  // G04 the top copy
endmodule
