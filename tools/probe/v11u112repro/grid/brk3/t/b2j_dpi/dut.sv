module m(input logic [7:0] x, output logic [7:0] y);
  typedef logic [7:0] b_t;
  import "DPI-C" function b_t cfun(input b_t v);
  function automatic b_t f(logic [7:0] v); return b_t'(v); endfunction
  assign y = f(x);
endmodule
