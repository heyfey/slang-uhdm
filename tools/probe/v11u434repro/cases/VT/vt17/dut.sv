// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  module inner;
    typedef logic [$clog2(W)-1:0] t;
    t x;
  endmodule
  inner u();
endmodule
