// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module leaf import p::*; (input logic [31:0] x [2], output logic [31:0] z [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign z[i] = x[i][31:W];
  end
endmodule
module top (input logic [31:0] x [2], output logic [31:0] z [2]);
  leaf u (.*);
endmodule
