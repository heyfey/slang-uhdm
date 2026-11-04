// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    if (1) begin : h
      assign y = idx_t'(a);
    end
  end
endmodule
