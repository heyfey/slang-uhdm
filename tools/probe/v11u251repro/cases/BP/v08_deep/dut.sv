// § bindIfacePortRefDefName251 (the target three levels down)
module ADD_SUB(input clk, input [7:0] a0);
  logic [7:0] r;
  localparam logic [7:0] W = 8'd3;
endmodule
interface add_sub_if(input bit clk, input [7:0] a);
endinterface
bind ADD_SUB add_sub_if add_sub_if0(.clk(clk), .a(a0));
module m2(input clk, input [7:0] a); ADD_SUB u(.clk(clk), .a0(a)); endmodule
module m1(input clk, input [7:0] a); m2 v(.clk(clk), .a(a)); endmodule
module top; logic clk; logic [7:0] x; m1 w(.clk(clk), .a(x)); endmodule
