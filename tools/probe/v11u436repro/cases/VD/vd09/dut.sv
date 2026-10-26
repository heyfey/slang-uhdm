// § ifaceDefArrNetDimSym436
interface inner #(int N = 2);
  logic w [N];
endinterface
interface outer;
  inner #(.N(3)) u();
endinterface
module top;
  outer o();
endmodule
