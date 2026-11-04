// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module sub #(parameter int N = 1); import t::*; vt_t h; if (N > 1) begin : g vt_t q; end endmodule
module top; sub #(2) u1(); sub u2(); endmodule
