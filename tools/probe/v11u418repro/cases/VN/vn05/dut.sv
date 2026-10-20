// § unnamedGateTermDefName418
module m (input [3:0] a, output y);
  and (y, a[1:0] == 2'b01, a[2]);
endmodule
