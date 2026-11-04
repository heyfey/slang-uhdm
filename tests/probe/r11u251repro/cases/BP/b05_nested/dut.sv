// § bindIfacePortRefDefName251
module ADD_SUB(input clk, input [7:0] a0);
endmodule
interface add_sub_if(input bit clk, input [7:0] a);
endinterface
bind ADD_SUB add_sub_if add_sub_if0(.clk(clk), .a(a0));
module mid(input clk, input [7:0] a); ADD_SUB u(.clk(clk), .a0(a)); endmodule
module top; logic clk; logic [7:0] x; mid m(.clk(clk), .a(x)); endmodule
