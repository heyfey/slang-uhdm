// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic signed [2:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = signed'(idx_t'(a)) + 3'sd1;
  end
endmodule
