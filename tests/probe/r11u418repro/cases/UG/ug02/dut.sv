// § unnamedGateTermDefName418
module m (input [1:0] a, output [1:0] y);
  and (y[0], a[0], a[1]);
  or (y[1], a[1], a[0]);
endmodule
