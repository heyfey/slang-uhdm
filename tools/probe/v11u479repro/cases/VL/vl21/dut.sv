// § vifTdClsScopedAbstain479v
interface ifc (input logic clk); logic a; modport mp(input a); endinterface
package p; class K; typedef virtual ifc v_t; endclass endpackage
module top; initial begin p::K::v_t g; end endmodule
