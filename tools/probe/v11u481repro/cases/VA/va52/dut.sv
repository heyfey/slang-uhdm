// § visibleParamAbstain481v
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  parameter int g = 3;
endpackage
module top; import t::vt_t; import t::g; int x;
  initial begin vt_t g; g = null; end
endmodule
