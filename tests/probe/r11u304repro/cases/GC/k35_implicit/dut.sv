// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  assign n = a;
  if (1) begin : g
    assign y = idx_t'(n);
  end
endmodule
