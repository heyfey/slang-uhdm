// § vifTdLocalIsRefVar479
interface ifc (input logic clk); logic a; endinterface
class C;
  typedef virtual ifc v_t;
  task t(); begin v_t g; end endtask
endclass
module top; C c; endmodule
