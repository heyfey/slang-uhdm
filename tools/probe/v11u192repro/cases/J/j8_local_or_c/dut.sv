// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module leaf import p::*; (input logic [31:0] x, output logic [31:0] z [2], output logic [31:0] q [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    wire [31:0] t;
    assign t = x[W:0] | 32'd1;
    assign z[i] = t;
    assign q[i] = x;
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] z [2], output logic [31:0] q [2]);
  leaf u (.*);
endmodule
