// § genCaCastTdAliasScopedName304
module top (input logic [7:0] a, output logic [7:0] y);
  for (genvar i = 1; i < 3; i++) begin : g
    localparam int L = i;
    typedef logic [L:0] t_t;
    assign y[3*i+:2] = 2'(t_t'(a));
  end
  assign y[2:0] = 3'b0;
endmodule
