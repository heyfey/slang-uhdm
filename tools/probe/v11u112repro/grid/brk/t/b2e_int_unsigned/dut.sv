module m(input logic [7:0] x, output logic [31:0] y, output logic [31:0] z);
  typedef int unsigned u_t;
  typedef integer i_t;
  function automatic u_t f(logic [7:0] v); f = u_t'(v); endfunction
  function automatic i_t g(logic [7:0] v); g = i_t'(v); endfunction
  assign y = f(x);
  assign z = g(x);
endmodule
