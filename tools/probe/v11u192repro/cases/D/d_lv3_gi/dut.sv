// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module leaf import p::*; (input logic [31:0] x [2], output logic [31:0] z [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign z[i] = {x[i][31:W], {W{1'b0}}};
  end
endmodule
module mid1 (input logic [31:0] x [2], output logic [31:0] z [2]);
  leaf u1 (.*);
endmodule
module mid2 (input logic [31:0] x [2], output logic [31:0] z [2]);
  mid1 u2 (.*);
endmodule
module top (input logic [31:0] x [2], output logic [31:0] z [2]);
  mid2 u0 (.*);
endmodule
