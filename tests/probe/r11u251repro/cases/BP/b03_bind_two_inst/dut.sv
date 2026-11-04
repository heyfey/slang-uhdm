// § bindIfacePortRefDefName251
module ADD_SUB(input clk, input [7:0] a0);
endmodule
interface add_sub_if(input bit clk, input [7:0] a);
endinterface
bind ADD_SUB add_sub_if add_sub_if0(.clk(clk), .a(a0));
module top; logic clk; logic [7:0] x; ADD_SUB dut1(.clk(clk), .a0(x)); ADD_SUB dut2(.clk(clk), .a0(x)); endmodule
