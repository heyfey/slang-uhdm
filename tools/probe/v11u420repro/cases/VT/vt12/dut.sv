// § unpackedStructVarPosInit420
module top;
  struct { int a; struct packed { logic [3:0] h; } p; } s = '{7, 4'h2};
endmodule
