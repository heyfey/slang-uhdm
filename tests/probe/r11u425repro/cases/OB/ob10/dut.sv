// § oneTickUpperBNormalized425
module top(input clk, input a, output logic q);
  wire w = 1'B1;
  always_ff @(posedge clk) q <= a ? 1'B1 : 1'B0;
endmodule
