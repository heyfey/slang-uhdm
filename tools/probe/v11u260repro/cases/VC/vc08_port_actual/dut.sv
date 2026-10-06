// § castStructInstCopy260 (the cast as a port actual)
module sub (input logic [7:0] x, output logic y);
  assign y = ^x;
endmodule
module m (input logic [7:0] w, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  sub s (.x(t_t'(w)), .y(o));
endmodule
module top;
  logic [7:0] w; logic o;
  m u (.w(w), .o(o));
endmodule
