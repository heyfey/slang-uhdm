package p;
  typedef union packed { logic [8-1:0] a; logic [7:0] b; } u_t;
  function automatic logic [7:0] f(logic [7:0] x);
    u_t t;
    t = u_t'(x);
    return t.a;
  endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  assign o = p::f(i);
endmodule
