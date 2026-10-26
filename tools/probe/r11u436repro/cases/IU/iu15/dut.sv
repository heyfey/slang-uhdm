// § ifaceDefArrNetDimSym436
parameter D = 5;
interface ifc #(int N = 2);
  logic [3:0] iv [D];
  logic w [N];
endinterface
module m(input clk);
  ifc i();
endmodule
