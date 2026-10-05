// § bindIfacePortRefDefName251
module ADD_SUB(input clk, input [7:0] a0);
endmodule
module chk(input bit clk, input [7:0] a);
endmodule
bind ADD_SUB chk chk0(.clk(clk), .a(a0));
module top; logic clk; logic [7:0] x; ADD_SUB dut(.clk(clk), .a0(x)); endmodule
