// § genForWholeLhsNestedKeep192v
package p;
  parameter int unsigned W = $clog2(16);
endpackage
module leaf import p::*; (input logic [31:0] x, output wire [31:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    assign z = {x[31:W], {W{1'b0}}};
  end
endmodule
module top (input logic [31:0] x, output wire [31:0] z);
  leaf u (.*);
endmodule
