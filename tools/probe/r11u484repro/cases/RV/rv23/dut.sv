// § modAliasTdAtBaseClone484 (module alias of a module packed union and of a module struct, used by nets)
module top(input logic [7:0] i, output logic [7:0] o);
  typedef union packed { logic [7:0] a; logic [7:0] b; } u_t;
  typedef u_t u2_t;
  typedef struct packed { logic [3:0] h; logic [3:0] l; } s_t;
  typedef s_t s2_t;
  u2_t w;
  s2_t v;
  assign w = i;
  assign v = w.a;
  assign o = v;
endmodule
