// § vifTdClsScopedAbstain479v
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
class K; typedef virtual ifc v_t; endclass
class D; task tk(); begin K::v_t g; end endtask endclass
module top; D d; endmodule
