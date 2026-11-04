// § modTdRangeClogKeeps434
module top #(parameter W = 4) (input logic [W-1:0] a);
  typedef logic [$clog2(W)-1:0] t;
endmodule
