// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  typedef enum logic [$clog2(W)-1:0] {A, B, C} e_t;
  e_t x;
endmodule
