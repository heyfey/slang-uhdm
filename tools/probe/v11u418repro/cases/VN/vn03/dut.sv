// § unnamedGateTermDefName418
module m (input [1:0] a, output [1:0] y);
  for (genvar i = 0; i < 2; i = i + 1) begin : b
    not (y[i], a[i]);
  end
endmodule
