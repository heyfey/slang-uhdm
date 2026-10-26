// § modTdRangeClogKeeps434
`define MAX(a,b) (((a)>(b))?(a):(b))
module top #(parameter W = 4) (input logic [W-1:0] a);
  typedef logic [`MAX($clog2(W),1)-1:0] t;
  t x;
endmodule
