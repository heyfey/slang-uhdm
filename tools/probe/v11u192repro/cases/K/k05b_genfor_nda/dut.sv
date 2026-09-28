// § ndaPsBoundOwner192
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module top import p::*; (input logic [31:0] x, output logic [31:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    wire [31:0] w = x[W:0];
    assign y[i] = w;
  end
endmodule
