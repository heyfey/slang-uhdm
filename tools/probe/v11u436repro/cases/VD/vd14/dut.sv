// § ifaceDefArrNetDimSym436
parameter D = 5;
interface ifc #(int D = 2);
  logic w [D];
endinterface
module top;
  ifc i();
endmodule
