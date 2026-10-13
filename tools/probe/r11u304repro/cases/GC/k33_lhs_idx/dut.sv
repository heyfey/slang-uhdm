// § genCaCastTdAliasScopedName304
module top (input logic a, input logic [2:0] s, output logic [7:0] y);
  typedef logic [2:0] idx_t;
  if (1) begin : g
    assign y[idx_t'(1)] = a;
  end
endmodule
