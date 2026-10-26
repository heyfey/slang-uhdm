// § modTdRangeClogKeeps434
interface ifc #(parameter W = 8);
  typedef logic [$clog2(W)-1:0] t;
  t x;
endinterface
module top;
  ifc u();
endmodule
