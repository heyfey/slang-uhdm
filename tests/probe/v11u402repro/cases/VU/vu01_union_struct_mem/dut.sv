// § modUnpackedUnionTd402
module top;
  typedef struct { int a; int b; } s_t;
  typedef union { s_t s; longint l; } u_t;
  u_t u;
endmodule
