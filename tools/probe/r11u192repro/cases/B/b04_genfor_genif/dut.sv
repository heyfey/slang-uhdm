// § genForReplCountOwner192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2 [2], output logic [31:0] y3 [2], output logic [31:0] y4 [2], output logic [31:0] y5 [2], output logic [31:0] y6);
  assign y1 = {{S{1'b0}}, x[27:0]};
  for (genvar g = 0; g < 2; g++) begin : gb
    assign y2[g] = x[S:0];
    assign y3[g] = {1'b0, x[S:0]};
    assign y4[g] = {{S{1'b0}}, x[27:0]};
    assign y5[g] = x[S:0] + x[31:S];
  end
  if (1) begin : gi
    assign y6 = {1'b0, x[S:0]};
  end
endmodule
