// § vifTdRefVarLocalImplicitNet481
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
endpackage
module top; import t::*; int x;
  task automatic tk(); vt_t g; fork begin g = null; end join_none endtask
  initial tk();
endmodule
