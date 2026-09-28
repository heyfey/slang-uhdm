// § psBoundPaOwnerName192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, input logic s, output logic [31:0] y, output logic [31:0] z);
  if (W > 1) begin : gi
    assign y[W:0] = x[W:0];
    assign z = s ? x[W:0] : x[31:W];
  end
endmodule
