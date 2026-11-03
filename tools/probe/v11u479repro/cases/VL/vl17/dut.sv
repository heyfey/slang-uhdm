// § vifTdClsScopedAbstain479v
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
class K; typedef virtual ifc v_t; endclass
module top; initial begin K::v_t g; end endmodule
