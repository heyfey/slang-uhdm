package p;
  typedef enum logic [2-1:0] { A, B, C } e_t;
  function automatic e_t f(logic [1:0] x);
    return e_t'(x);
  endfunction
endpackage
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = p::f(i);
endmodule
