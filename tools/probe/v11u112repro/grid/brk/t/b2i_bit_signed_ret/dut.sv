module m(input logic [7:0] x, output logic [7:0] y, output logic [7:0] z);
  typedef bit signed [7:0] sb_t;
  typedef logic [7:0] b_t;
  function automatic sb_t f(logic [7:0] v); return sb_t'(v); endfunction
  function automatic b_t g(logic [7:0] v); b_t r; r = v; return r; endfunction
  assign y = f(x);
  assign z = g(x);
endmodule
