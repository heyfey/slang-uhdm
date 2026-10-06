// § castStructInstCopy260 (two casts to the same typedef in one instance)
module m (input logic [31:0] w, v, output logic [5:0] o);
  typedef struct packed { logic [25:0] a; logic [5:0] x; } t_t;
  t_t r, s;
  assign r = t_t'(w);
  assign s = t_t'(v);
  assign o = r.x ^ s.x;
endmodule
module top;
  logic [31:0] w, v; logic [5:0] o;
  m u (.w(w), .v(v), .o(o));
endmodule
