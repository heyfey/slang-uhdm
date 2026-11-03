// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*;
  class K; function void m(); vt_t g; g = null; endfunction endclass
  initial begin K k; k = new(); k.m(); end
endmodule
