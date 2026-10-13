// § genCaCastTdAliasScopedName304
module top (input logic [7:0] x, output logic [7:0] y);
  typedef logic [7:0] b_t;
  for (genvar i = 0; i < 2; i++) begin : g
    logic [7:0] w;
    assign w = b_t'(x);
  end
  assign y = g[0].w;
endmodule
