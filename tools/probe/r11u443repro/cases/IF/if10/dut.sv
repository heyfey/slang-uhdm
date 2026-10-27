// § elabIfaceLoopVarReadBinds443
interface ifc(input logic clk); logic [3:0] sig; int s; always @(posedge clk) foreach (sig[i]) s <= s + i; endinterface
module top; logic c; ifc u(c); endmodule
