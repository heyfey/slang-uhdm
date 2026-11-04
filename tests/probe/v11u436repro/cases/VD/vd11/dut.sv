// § ifaceDefArrNetDimSym436
parameter D = 5;
interface ifc #(int N = 2);
  logic [3:0] iv [D];
  logic x [N];
endinterface
module top;
  ifc i();
  assign i.x[0] = 1'b1;
endmodule
