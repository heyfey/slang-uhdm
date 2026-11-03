// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; endinterface
typedef virtual ifc vt_t;
class C;
  task t(); begin vt_t g; end endtask
endclass
module top; C c; endmodule
