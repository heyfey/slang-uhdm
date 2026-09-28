// § psBoundPaOwnerName192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
module top import p::*; #(parameter int M = 1) (input logic [31:0] x, output logic [31:0] y1, y2, y3, y4, y5, y6, y7, y8);
  if (M == 1) begin : gi
    assign y1 = x[S:0];
    assign y2 = {1'b0, x[S:0]};
    assign y3 = {{S{1'b0}}, x[27:0]};
  end
  case (M)
    1: begin : gc
      assign y4 = {1'b0, x[S:0]};
    end
  endcase
  for (genvar g = 0; g < 1; g++) begin : gf
    assign y6 = '0;
  end
  assign y7 = '0;
  for (genvar g = 0; g < 1; g++) begin : gf2
    assign y5 = '0;
    assign y8 = {1'b0, x[S-1:0]};
  end
endmodule
