// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; logic x;
  function logic f(input vt_t v); return 1; endfunction
  initial begin vt_t g; void'(f(g)); end
endmodule
