// § vlogEnumBaseKwSpan235
`define MKENUM(name) typedef enum bit [1:0] {name``_A, name``_B} name``_t;
module top(output [1:0] o);
  `MKENUM(foo)
  foo_t x;
  assign o = x;
endmodule
