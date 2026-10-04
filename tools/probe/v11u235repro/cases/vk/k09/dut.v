// § vlogEnumBaseKwSpan235
module top(output [2:0] o);
  typedef enum bit /* c */ [2:0] {A, B} e_t;
  typedef enum int unsigned {C, D} i_t;
  typedef enum integer {E, F} n_t;
  e_t x; i_t y; n_t z;
  assign o = x;
endmodule
