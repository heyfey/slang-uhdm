// § vlogEnumBaseKwSpan235
module top(output [2:0] o);
  typedef enum logic
    [2:0] {A, B} e_t;
  e_t x;
  assign o = x;
endmodule
