// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef int i_t;
  typedef virtual ifc vt_t;
  typedef logic [3:0] n_t;
  parameter int P = 3;
endpackage
module top; import t::*; vt_t h; n_t n; i_t i; endmodule
