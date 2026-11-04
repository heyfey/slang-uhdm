// § ifaceDefArrNetDimSym436
interface ifc #(int N = 2);
  logic w [N];
endinterface
module top;
  ifc #(.N(3)) a();
  ifc #(.N(4)) b();
endmodule
