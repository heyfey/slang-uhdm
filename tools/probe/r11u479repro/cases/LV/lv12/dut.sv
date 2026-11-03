// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; endinterface
package t;
  typedef virtual ifc vt_t;
  class C; task t(); begin vt_t g; end endtask endclass
endpackage
module top; import t::*; C c; endmodule
