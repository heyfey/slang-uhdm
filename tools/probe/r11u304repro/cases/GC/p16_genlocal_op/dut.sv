// § genCaCastTdAliasScopedName304
module top (input logic [7:0] x, output logic [7:0] y);
  typedef logic [7:0] b_t;
  if (1) begin : g
    logic [7:0] w;
    assign w = b_t'(x) + x;
    assign y = w;
  end
endmodule
