// § enumAliasClone161 — a module alias of an enum with the default int base
module top(output int o);
  typedef enum {A, B} e_t;
  typedef e_t f_t;
  f_t v;
  assign v = B;
  assign o = v;
endmodule
