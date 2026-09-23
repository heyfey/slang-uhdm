module top(input logic [15:0] a, output logic [15:0] y, z);
  typedef logic signed [15:0] s_t;
  function automatic s_t f1(input logic [15:0] x); f1 = s_t'(x); endfunction
  function automatic s_t f2(input logic [15:0] x); f2 = s_t'(x) + s_t'(1); endfunction
  assign y = f1(a);
  assign z = f2(a);
endmodule
