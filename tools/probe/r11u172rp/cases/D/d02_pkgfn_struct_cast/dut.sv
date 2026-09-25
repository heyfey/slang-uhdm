package p;
  typedef logic [3-1:0] f_t;
  typedef struct packed { f_t a; logic [5-1:0] b; } s_t;
  function automatic logic [2:0] g(s_t v);
    return v.a;
  endfunction
  function automatic logic [2:0] f(logic [7:0] x);
    return g(s_t'(x));
  endfunction
endpackage
module top(input logic [7:0] i, output logic [2:0] o);
  assign o = p::f(i);
endmodule
