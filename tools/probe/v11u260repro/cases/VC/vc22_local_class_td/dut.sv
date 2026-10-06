// § castStructInstCopy260 (a struct typedef in a module-local class, cast through the class scope)
module m (input logic [7:0] w, output logic [3:0] o);
  class C;
    typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  endclass
  C::t_t r;
  assign r = C::t_t'(w);
  assign o = r.a;
endmodule
module top;
  logic [7:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
