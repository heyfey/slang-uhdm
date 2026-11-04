// § genCaSelBoundUnsizedClone282
package p; parameter int unsigned S = 4; endpackage
module m import p::*; (input logic [1:0] c, input logic [7:0] x, output logic [7:0] y6 [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y6[g] = x[S:0] | 8'd0;
  end
endmodule
module top(input logic [1:0] c, input logic [7:0] x, output logic [7:0] y6 [2]); m u(.c(c), .x(x), .y6(y6)); endmodule
