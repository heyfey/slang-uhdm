// § psBoundPaOwnerName192 § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = 5;
endpackage
module sub import p::*; (input logic [31:0] x, output logic [31:0] y [3], output logic [31:0] z, output logic [31:0] v);
  for (genvar i = 0; i < 3; i++) begin : g
    assign y[i] = x[W+i:i] + 32'd1;
  end
  for (genvar j = 0; j < 1; j++) begin : h
    assign z = ~x[W:0];
    assign v = x[W:0];
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] y [3], output logic [31:0] z, output logic [31:0] v);
  sub u (.*);
endmodule
