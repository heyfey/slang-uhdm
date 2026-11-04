// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  typedef logic [$clog2(W)-1:0] t;
  t x;
  localparam int L = $bits(t);
  logic [L-1:0] y;
endmodule
