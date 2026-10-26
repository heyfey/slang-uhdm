// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  typedef logic [W-1:0] t;
  typedef logic [$clog2($bits(t))-1:0] u;
  u x;
endmodule
