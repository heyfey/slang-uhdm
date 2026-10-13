// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic [1:0] y);
  if (1) begin : g
    typedef logic [1:0] l_t;
    assign y = l_t'(a);
  end
endmodule
