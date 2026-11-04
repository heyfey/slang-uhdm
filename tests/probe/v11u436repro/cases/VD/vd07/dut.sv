// § ifaceDefArrNetDimSym436
parameter D = 5;
interface ifc;
  logic [3:0] iv [D];
endinterface
module top;
  for (genvar k = 0; k < 2; k++) begin : g
    ifc i();
  end
endmodule
