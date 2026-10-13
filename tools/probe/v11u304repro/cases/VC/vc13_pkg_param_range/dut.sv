// § genCaCastTdAliasScopedName304
package pk;
  parameter int W = 3;
endpackage
module top (input logic [3:0] a, output logic [2:0] y);
  typedef logic [pk::W-1:0] idx_t;
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule
