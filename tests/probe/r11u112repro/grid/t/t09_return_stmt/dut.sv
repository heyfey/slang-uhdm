module top(input logic [7:0] a, output logic [7:0] y);
  typedef logic signed [7:0] t;
  function automatic t f(input logic [7:0] x); return t'(x); endfunction
  assign y = f(a);
endmodule
