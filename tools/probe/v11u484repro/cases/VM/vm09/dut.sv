// § modAliasTdAtBaseClone484 (module alias of a union with a struct member)
module top(input logic [7:0] i, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  typedef union packed { s_t s; logic [7:0] r; } u_t;
  typedef u_t u2_t;
  u2_t w;
  assign w.r = i;
  assign o = w.s.b;
endmodule
