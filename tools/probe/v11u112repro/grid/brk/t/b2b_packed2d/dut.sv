module m(input logic [7:0] x, output logic [7:0] y);
  typedef logic [1:0][3:0] p_t;
  function automatic p_t f(logic [7:0] v); return p_t'(v); endfunction
  assign y = f(x);
endmodule
