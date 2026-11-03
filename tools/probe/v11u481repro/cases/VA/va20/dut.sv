// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  function automatic bit f(); vt_t g; g = null; return g == null; endfunction
  initial $display(f());
endmodule
