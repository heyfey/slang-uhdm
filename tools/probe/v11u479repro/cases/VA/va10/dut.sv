// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
  class cfg; vt_t vif; function void set(vt_t v); vif = v; endfunction endclass
endpackage
module top; import t::*; logic clk; ifc u(clk); vt_t h; cfg c; initial begin c = new; h = u; c.set(h); end endmodule
