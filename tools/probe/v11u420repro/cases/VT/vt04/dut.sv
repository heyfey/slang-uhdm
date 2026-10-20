// § unpackedStructVarPosInit420
module top;
  if (1) begin : g
    struct { int a; int b; } s = '{3, 4};
  end
endmodule
