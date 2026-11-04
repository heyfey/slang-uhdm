// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y [2][2], output logic [31:0] z [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign z[i] = x[W:0];
    for (genvar j = 0; j < 2; j++) begin : h
      assign y[i][j] = x[W:0];
    end
  end
endmodule
