// § vlogEnumBaseKwSpan235
module top(output [2:0] o);
`ifdef NOTDEF
  typedef enum logic [2:0] {A, B, C} e_t;
`else
  typedef enum bit [2:0] {A, B, C} e_t;
`endif
  e_t x;
  assign o = x;
endmodule
