// § bindIfacePortRefDefName251 (implicit named port connections .clk)
module ADD_SUB(input clk, input [7:0] a0);
  logic [7:0] r;
  localparam logic [7:0] W = 8'd3;
endmodule
interface add_sub_if(input logic clk, input [7:0] a);
endinterface
bind ADD_SUB add_sub_if add_sub_if0(.clk, .a(a0));
module top; logic clk; logic [7:0] x; ADD_SUB dut(.clk(clk), .a0(x)); endmodule
