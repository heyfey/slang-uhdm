module top(input logic [7:0] a, output logic [7:0] y);
  typedef logic [7:0] t;
  function automatic logic [7:0] g(input logic [7:0] x); g = t'(x); endfunction
  assign y = g(a);
endmodule
