// § unnamedGateTermDefName418
module m #(parameter N = 1) (input [1:0] a, output y);
  if (N == 1) begin : g
    or (y, a[0], a[1]);
  end
endmodule
