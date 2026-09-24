// § defNetTypedefEndWrite134
// case e01: a dynamic array and a queue of a module struct typedef
module top(output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t d [];
  s_t q [$];
  s_t f [2];
  assign o = f[0].a;
endmodule
