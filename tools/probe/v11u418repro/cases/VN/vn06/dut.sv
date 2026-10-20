// § unnamedGateTermDefName418
module m (input [1:0] a, output [1:0] y);
  pullup (y[0]);
  and (y[1], a[0], a[1]);
endmodule
