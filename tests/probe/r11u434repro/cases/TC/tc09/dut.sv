// § modTdRangeClogKeeps434
module child #(parameter W = 4) (input logic [W-1:0] a);
  typedef logic [$clog2(W)-1:0] t;
  t x;
endmodule
module top;
  logic [15:0] a;
  child #(.W(16)) u (.a(a));
endmodule
