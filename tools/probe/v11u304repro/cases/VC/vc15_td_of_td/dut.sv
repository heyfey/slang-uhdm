// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic [1:0] y);
  typedef logic [1:0] a_t;
  typedef a_t b_t;
  if (1) begin : g
    assign y = b_t'(a);
  end
endmodule
