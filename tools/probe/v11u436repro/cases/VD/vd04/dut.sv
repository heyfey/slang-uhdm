// § ifaceDefArrNetDimSym436
interface ifc #(int N = 2);
  localparam int L = N + 1;
  logic w [L];
endinterface
module top;
  ifc i();
endmodule
