// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  typedef logic [$clog2(W)-1:0] t;
  typedef t t2;
  t2 x;
endmodule
