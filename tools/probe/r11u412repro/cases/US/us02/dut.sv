// § unpStructArrElemVar412
module top();
  struct { int a; logic [3:0] b; } s [2];
  typedef union { int a; real r; } u_t;
  u_t u [2];
  typedef struct packed { logic [3:0] a; } p_t;
  p_t p [2];
endmodule
