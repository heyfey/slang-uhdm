// § unnamedGateTermDefName418
module m (input [1:0] a, input b, output y);
  xor (y, {a[0], b}, ~a[1]);
endmodule
