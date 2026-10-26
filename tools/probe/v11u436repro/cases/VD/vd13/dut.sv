// § ifaceDefArrNetDimSym436
module m;
  parameter D = 3;
endmodule
interface ifc #(int D = 2);
  logic w [D];
endinterface
module top;
  ifc i();
  m u();
endmodule
