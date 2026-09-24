module m(input logic [7:0] x, output logic [7:0] y);
  typedef logic [7:0] b_t;
  function automatic logic [7:0] f(logic [7:0] v);
    b_t t;
    t = b_t'(v) ^ 8'h5a;
    return t;
  endfunction
  assign y = f(x);
endmodule
