// § pkgVirtIfaceTd479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package t;
  typedef virtual ifc vt_t;
  typedef struct packed { logic [3:0] a; } s_t;
endpackage
package u;
  import t::*;
  vt_t q;
  s_t r;
endpackage
module top; import u::*; import t::*; vt_t h; s_t s; endmodule
