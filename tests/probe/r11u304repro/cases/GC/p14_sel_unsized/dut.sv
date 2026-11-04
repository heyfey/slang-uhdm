// § genCaCastTdAliasScopedName304
module top (input logic [7:0] x, output logic [7:0] o[2]);
  typedef logic [7:0] b_t;
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = b_t'(x) + 1;
  end
endmodule
