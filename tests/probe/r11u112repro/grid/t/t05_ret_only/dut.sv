module top(input logic [7:0] a, output logic [7:0] y);
  typedef logic [7:0] t;
  function automatic t f(input logic [7:0] x); f = x + 8'd1; endfunction
  assign y = f(a);
endmodule
