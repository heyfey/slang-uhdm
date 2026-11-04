// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module leaf import p::*; (input logic [31:0] x [1], output logic [31:0] z [1]);
  for (genvar i = 0; i < 1; i++) begin : g
    assign z[i] = {x[i][31:W], {W{1'b0}}};
  end
endmodule
module top (input logic [31:0] x [1], output logic [31:0] z [1]);
  leaf u (.*);
endmodule
