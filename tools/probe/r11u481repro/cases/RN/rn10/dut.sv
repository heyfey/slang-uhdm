// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
program top; import t::*;
  initial begin vt_t g; g = null; end
endprogram
