module m(input logic [7:0] x, output logic [7:0] y);
  typedef logic [7:0] b_t;
  function automatic b_t f(logic [7:0] v); b_t t; t = b_t'(v); return t; endfunction
  function automatic b_t g(logic [7:0] v); return f(v) + b_t'(1); endfunction
  assign y = g(x);
endmodule
