// § castStructInstCopy260 (two modules each declaring their own t_t, both casting)
module m1 (input logic [7:0] w, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t r;
  assign r = t_t'(w);
  assign o = r.a;
endmodule
module m2 (input logic [7:0] w, output logic [3:0] o);
  typedef struct packed { logic [1:0] c; logic [5:0] d; } t_t;
  t_t r;
  assign r = t_t'(w);
  assign o = r.d[3:0];
endmodule
module top;
  logic [7:0] w; logic [3:0] o1, o2;
  m1 u1 (.w(w), .o(o1));
  m2 u2 (.w(w), .o(o2));
endmodule
