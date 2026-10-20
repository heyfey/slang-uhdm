// § unpackedStructVarPosInit420
interface ifc;
  struct { int a; int b; } s = '{1, 2};
endinterface
module top;
  ifc u();
endmodule
