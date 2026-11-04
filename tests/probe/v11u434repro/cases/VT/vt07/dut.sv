// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  typedef logic signed [$clog2(W)-1:0] t;
  t x;
endmodule
