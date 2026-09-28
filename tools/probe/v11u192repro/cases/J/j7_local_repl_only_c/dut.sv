// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module leaf import p::*; (input logic [31:0] x, output logic [31:0] z [2], output logic [31:0] q [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    wire [31:0] t;
    assign t = {{W{1'b0}}, x[0]};
    assign z[i] = t;
    assign q[i] = x[W:0];
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] z [2], output logic [31:0] q [2]);
  leaf u (.*);
endmodule
