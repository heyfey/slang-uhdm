// § defNetTypeParamPackedVec160
module sub #(parameter type T = logic signed [7:0], parameter int N = 2) (input logic clk, output T [N-1:0] q);
  T [N-1:0] r;
  always_ff @(posedge clk) r <= '0;
  assign q = r;
endmodule
module top (input logic clk, output logic signed [7:0] [1:0] q); sub u(.clk(clk), .q(q)); endmodule
