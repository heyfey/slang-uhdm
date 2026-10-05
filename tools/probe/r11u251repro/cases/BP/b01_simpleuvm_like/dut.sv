// § bindIfacePortRefDefName251
module ADD_SUB(input clk, input [7:0] a0, output reg [8:0] result0);
  always @(posedge clk) result0 <= a0 + 1;
endmodule
interface add_sub_if(input bit clk, input [7:0] a, input [8:0] result);
endinterface
bind ADD_SUB add_sub_if add_sub_if0(.clk(clk), .a(a0), .result(result0));
module top; logic clk; logic [7:0] x; wire [8:0] y; ADD_SUB dut(.clk(clk), .a0(x), .result0(y)); endmodule
