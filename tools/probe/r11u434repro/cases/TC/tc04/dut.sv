// § modTdRangeClogKeeps434
module top;
  localparam int L = 8;
  typedef logic [$clog2(L)-1:0] t;
  t x;
endmodule
