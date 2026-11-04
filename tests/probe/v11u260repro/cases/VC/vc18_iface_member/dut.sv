// § castStructInstCopy260 (the cast assigned to an interface instance's member in a module)
interface ifc;
  logic [7:0] d;
endinterface
module m (input logic [7:0] w, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  ifc i ();
  t_t r;
  assign i.d = w;
  assign r = t_t'(i.d);
  assign o = r.a;
endmodule
module top;
  logic [7:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
