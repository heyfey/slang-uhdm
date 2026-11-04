package p;
  typedef bit [8-1:0] b_t;
  function automatic b_t f(logic [7:0] x);
    return b_t'(x);
  endfunction
endpackage
module top(input logic [7:0] i, output logic [7:0] o);
  assign o = p::f(i);
endmodule
