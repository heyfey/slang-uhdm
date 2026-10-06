// § castStructInstCopy260 (a class-scoped struct typedef in a package, cast in an instance)
package p;
  class C;
    typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  endclass
endpackage
module m (input logic [7:0] w, output logic [3:0] o);
  p::C::t_t r;
  assign r = p::C::t_t'(w);
  assign o = r.a;
endmodule
module top;
  logic [7:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
