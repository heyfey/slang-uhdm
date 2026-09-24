module c #(parameter int W = 4) (input logic [7:0] x, output logic [W-1:0] y);
  typedef logic [W-1:0] w_t;
  function automatic w_t f(logic [7:0] v); f = w_t'(v); endfunction
  always_comb y = f(x);
endmodule
module m(input logic [7:0] x, output logic [3:0] y4, output logic [7:0] y8);
  c #(.W(4)) u4(.x(x), .y(y4));
  c #(.W(8)) u8(.x(x), .y(y8));
endmodule
