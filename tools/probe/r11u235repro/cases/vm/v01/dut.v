// § vlogEnumBaseKwSpan235
module top(output [2:0] o);
  typedef enum bit [2:0] {A, B, C} e_t;
  e_t x;
  assign o = x;
endmodule
