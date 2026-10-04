// § vlogEnumBaseKwSpan235
module top(output [3:0] o);
  typedef enum bit [1:0][1:0] {A, B} e2_t;
  e2_t x;
  assign o = x;
endmodule
