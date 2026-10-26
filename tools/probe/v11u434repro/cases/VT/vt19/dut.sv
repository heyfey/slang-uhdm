// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  class C;
    typedef logic [$clog2(8)-1:0] t;
    t v;
  endclass
  typedef logic [$clog2(W)-1:0] t;
  t x;
endmodule
