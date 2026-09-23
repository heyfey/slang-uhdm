module top(input logic [31:0] a, output logic [31:0] y);
  typedef int i_t;
  function automatic i_t f(input logic [31:0] x); f = i_t'(x); endfunction
  assign y = f(a);
endmodule
