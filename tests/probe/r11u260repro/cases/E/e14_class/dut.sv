// § castStructInstCopy260 (the cast in a class method (no copy: a subroutine))
package p;
  typedef struct packed { logic [25:0] a; logic [5:0] x; } t_t;
  class c;
    function t_t f(logic [31:0] v);
      return t_t'(v);
    endfunction
  endclass
endpackage
module top (input logic [31:0] w, output logic [5:0] o);
  p::t_t rd;
  assign rd = p::t_t'(w);
  assign o = rd.x;
endmodule
