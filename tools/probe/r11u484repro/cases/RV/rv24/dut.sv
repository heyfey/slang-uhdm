// § modAliasTdAtBaseClone484 (alias of an alias in a module)
module top;
  typedef struct { int k; int d; } a_t;
  typedef a_t b_t;
  typedef b_t c_t;
  c_t v;
  int x;
  initial begin v.k = 1; x = v.k; end
endmodule
