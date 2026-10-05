// § bindIfacePortRefDefName251 (two interfaces bound to one target in one bind)
module ADD_SUB(input clk, input [7:0] a0);
  logic [7:0] r;
  localparam logic [7:0] W = 8'd3;
endmodule
interface add_sub_if(input bit clk, input [7:0] a);
endinterface
bind ADD_SUB add_sub_if i0(.clk(clk), .a(a0)), i1(.clk(clk), .a(r));
module top; logic clk; logic [7:0] x; ADD_SUB dut(.clk(clk), .a0(x)); endmodule
