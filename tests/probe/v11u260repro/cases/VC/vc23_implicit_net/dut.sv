// § castStructInstCopy260 (the cast of an implicit net created by a port connection)
module sub (output logic [7:0] y);
  assign y = 8'h3c;
endmodule
module m (output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t r;
  sub s (.y(iw));
  assign r = t_t'(iw);
  assign o = r.b;
endmodule
module top;
  logic [3:0] o;
  m u (.o(o));
endmodule
