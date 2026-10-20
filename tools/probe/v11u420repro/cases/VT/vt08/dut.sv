// § unpackedStructVarPosInit420
module top;
  localparam int P = 4;
  struct { int a; int b; } s = '{P, P+1};
endmodule
