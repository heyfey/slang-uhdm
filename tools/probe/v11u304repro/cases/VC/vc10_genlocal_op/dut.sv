// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    logic [1:0] z;
    assign z = idx_t'(a) + 2'b1;
    assign y = z;
  end
endmodule
