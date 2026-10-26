// § modTdRangeClogKeeps434
module top #(parameter W = 4) (input logic [W-1:0] a);
  typedef struct packed { logic [$clog2(W)-1:0] f; logic g; } t;
  t x;
endmodule
