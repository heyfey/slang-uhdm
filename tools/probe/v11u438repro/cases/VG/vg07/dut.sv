// § genNdaUnsizedFreshLhs438
module top(input [15:0] b, output [1:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    wire w = b['h4 + i];
    assign y[i] = w;
  end
endmodule
