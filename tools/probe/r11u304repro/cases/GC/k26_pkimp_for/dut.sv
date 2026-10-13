// § genCaCastTdAliasScopedName304
package pk; typedef logic [1:0] idx_t; endpackage
module top import pk::*; (input logic a, output logic [1:0] y);
  for (genvar i = 0; i < 1; i++) begin : g
    assign y = idx_t'(a) + 2'(i);
  end
endmodule
