module top(input logic [3:0] a, output logic [3:0] y);
  typedef bit [3:0] b_t;
  function automatic b_t f(input logic [3:0] x); f = b_t'(x); endfunction
  assign y = f(a);
endmodule
