// § genCaCastTdAliasScopedName304
module top (input logic a, s, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = s ? idx_t'(a) : 2'b0;
  end
endmodule
