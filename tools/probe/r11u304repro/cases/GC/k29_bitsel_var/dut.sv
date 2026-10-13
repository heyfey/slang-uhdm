// § genCaCastTdAliasScopedName304
module top (input logic [7:0] a, input logic [2:0] s, output logic y);
  typedef logic [2:0] idx_t;
  if (1) begin : g
    assign y = a[idx_t'(s)];
  end
endmodule
