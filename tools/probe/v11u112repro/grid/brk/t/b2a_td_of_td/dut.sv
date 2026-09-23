module m(input logic [7:0] x, output logic [7:0] y, output logic [7:0] z);
  typedef logic [7:0] b_t;
  typedef b_t c_t;
  function automatic c_t f(logic [7:0] v); f = c_t'(v + 1); endfunction
  assign y = f(x);
  assign z = c_t'(x);
endmodule
