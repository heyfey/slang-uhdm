// § vlogEnumBaseKwSpan235
`define ENUMT(n, b) typedef enum b [1:0] {n``_A, n``_B} n``_t;
module top(output [1:0] o);
  `ENUMT(foo, bit)
  `ENUMT(bar, logic)
  foo_t x;
  bar_t y;
  assign o = x ^ y;
endmodule
