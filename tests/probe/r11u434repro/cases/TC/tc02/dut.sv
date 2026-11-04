// § modTdRangeClogKeeps434
module top #(parameter W = 4) (input logic [W-1:0] a);
  typedef logic [$clog2(8)-1:0] t;
  t x;
endmodule
