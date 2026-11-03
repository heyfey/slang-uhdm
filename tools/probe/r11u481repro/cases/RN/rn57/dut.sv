// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  function automatic vt_t fn(); begin vt_t g; g = null; return g; end endfunction
endmodule
