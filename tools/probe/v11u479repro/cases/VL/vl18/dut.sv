// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
class B; typedef virtual ifc v_t; endclass
class D extends B; task tk(); begin v_t g; end endtask endclass
module top; D d; endmodule
