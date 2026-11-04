// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  typedef logic [W-1:$clog2(W)] t;
  t x;
endmodule
