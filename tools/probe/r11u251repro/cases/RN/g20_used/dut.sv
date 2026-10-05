// § regTdArrElabIsNet251
typedef reg [3:0] f_t[4];
module top(input clk, input [3:0] i, output [3:0] o); f_t x; always @(posedge clk) x[0] <= i; assign o = x[0]; endmodule
