// § castStructInstCopy260 (a typedef of a struct typedef)
module m (input logic [7:0] w, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  typedef t_t u_t;
  u_t r;
  assign r = u_t'(w);
  assign o = r.a;
endmodule
module top;
  logic [7:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
