// § enumCastChainKeepsInnerCast493
interface ifc;
  int a, b;
  assign b = int'(int'(a));
endinterface
module top;
  ifc i();
endmodule
