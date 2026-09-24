module top #(parameter int W = 12) (input logic [W-1:0] a, output logic [W-1:0] y);
  typedef logic [W-1:0] t;
  function automatic t f(input logic [W-1:0] x); f = t'(x); endfunction
  assign y = f(a);
endmodule
