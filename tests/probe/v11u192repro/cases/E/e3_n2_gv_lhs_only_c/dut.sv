// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module leaf import p::*; (input logic [31:0] x, output logic [31:0] z [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign z[i] = {x[31:W], {W{1'b0}}};
  end
endmodule
module top (input logic [31:0] x, output logic [31:0] z [2]);
  leaf u (.*);
endmodule
