// § vlogEnumBaseKwSpan235
`define BT bit
module top(output [2:0] o);
  typedef enum `BT [2:0] {A, B, C} e_t;
  e_t x;
  assign o = x;
endmodule
