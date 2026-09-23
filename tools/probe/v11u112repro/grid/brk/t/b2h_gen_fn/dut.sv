module m(input logic [7:0] x, output logic [7:0] y);
  typedef logic [7:0] b_t;
  if (1) begin : g
    function automatic b_t f(logic [7:0] v); f = b_t'(v); endfunction
    assign y = f(x);
  end
endmodule
