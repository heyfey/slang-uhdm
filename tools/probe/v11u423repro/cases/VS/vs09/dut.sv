// § unszBasedPkgFoldUnsized423
package p;
  parameter H = 'h4;
endpackage
module top(input logic [7:0] x, output logic [7:0] y);
  import p::*;
  for (genvar i = 0; i < H; i++) begin : g
    assign y[i] = x[i];
  end
  if (H > 2) begin : gi
    assign y[7:4] = x[7:4];
  end
endmodule
