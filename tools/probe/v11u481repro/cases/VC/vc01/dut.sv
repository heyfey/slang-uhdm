// § pkgVifLocalInitCopy481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; logic clk; ifc u(clk);
  initial begin vt_t g = u; end
endmodule
