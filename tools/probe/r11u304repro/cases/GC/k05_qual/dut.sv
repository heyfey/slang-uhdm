// § genCaCastTdAliasScopedName304
package pk; typedef logic [1:0] idx_t; endpackage
module top (input logic a, output logic [1:0] y);
  if (1) begin : g
    assign y = pk::idx_t'(a);
  end
endmodule
