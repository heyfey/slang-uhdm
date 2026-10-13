// § genCaCastTdAliasScopedName304
module top (input logic [7:0] x, output logic [7:0] y);
  typedef logic [7:0] b_t;
  for (genvar i = 0; i < 1; i++) begin : g
    assign y = (b_t'(x)) + (int'(i));
  end
endmodule
