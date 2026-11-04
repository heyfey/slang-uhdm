// § genCaCastTdAliasScopedName304
module top (input logic [7:0] x, output logic [15:0] y);
  typedef logic [7:0] b_t;
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[8*i +: 8] = b_t'(x) ^ x;
  end
endmodule
