// § bindIfacePortRefDefName251 (a parameterized interface bound with a parameter override)
module ADD_SUB(input clk, input [7:0] a0);
endmodule
interface add_sub_if #(parameter int W = 4)(input bit clk, input [W-1:0] a);
endinterface
bind ADD_SUB add_sub_if #(.W(8)) add_sub_if0(.clk(clk), .a(a0));
module top; logic clk; logic [7:0] x; ADD_SUB dut(.clk(clk), .a0(x)); endmodule
