// § vlogEnumBaseKwSpan235
module top(output [2:0] o);
  typedef enum bit unsigned [2:0] {A, B} eu_t;
  eu_t x;
  assign o = x;
endmodule
