// r10uvm219 grid arm E — THE MUST-STAY CONTROL FOR THE FORWARDED BLOCK.
// The same shape as arm A with NO bare `this` anywhere, so
// § thisImplicitNetBoth38 mints nothing and not one cell may move between the
// two binaries.
package pe0;
  int e0_own;
  class Ce0;
    int e0_prop;
    extern function void doit();
  endclass
  function void Ce0::doit();
    int e0_loc;
    e0_prop = e0_loc;
  endfunction
endpackage

module ge_nothis;
  import pe0::*;
  logic ge_clk;
  initial $dumpvars(0, ge_nothis);
endmodule
