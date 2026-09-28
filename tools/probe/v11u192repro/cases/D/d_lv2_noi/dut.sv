// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module leaf import p::*; (input logic [31:0] x, output logic [31:0] z);
  for (genvar i = 0; i < 1; i++) begin : g
    assign z = {x[31:W], {W{1'b0}}};
  end
endmodule
module mid1 (input logic [31:0] x, output logic [31:0] z);
  leaf u1 (.*);
endmodule
module top (input logic [31:0] x, output logic [31:0] z);
  mid1 u0 (.*);
endmodule
