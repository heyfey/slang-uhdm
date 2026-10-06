// § castStructInstCopy260 (a module-local class with an extern method casting this.v, and a module cast beside it)
module m (input logic [7:0] w, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  class k;
    logic [7:0] v;
    extern function t_t g();
  endclass
  function t_t k::g();
    return t_t'(this.v);
  endfunction
  t_t r;
  assign r = t_t'(w);
  assign o = r.a;
endmodule
module top;
  logic [7:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
