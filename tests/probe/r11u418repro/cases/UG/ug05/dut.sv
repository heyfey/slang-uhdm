// § unnamedGateTermDefName418
module m (input [3:0] a, output y);
  nand (y, a[1:0], a[3:2]);
endmodule
