// § vlogEnumBaseKwSpan235
module top #(parameter W = 3) (output [W-1:0] o);
  typedef enum bit [W-1:0] {A, B, C} e_t;
  e_t x;
  assign o = x;
endmodule
