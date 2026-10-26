// § ifaceDefArrNetDimSym436
interface ifc #(int N = 2);
  wire w [N] ;
  wire v [N] = '{default: 0};
endinterface
module top;
  ifc i();
endmodule
