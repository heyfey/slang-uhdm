// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  typedef logic [$clog2(W)-1:0] t;
  typedef struct packed { t a; logic b; } s_t;
  s_t x;
endmodule
