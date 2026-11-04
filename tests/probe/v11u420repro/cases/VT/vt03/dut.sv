// § unpackedStructVarPosInit420
module top;
  typedef struct { int x; } in_t;
  struct { int a; in_t n; } s = '{1, '{2}};
endmodule
