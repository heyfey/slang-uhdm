// § genLoopDirectBoundPaCopy280
// a package parameter defaulted by a replication, imported
package pk;
  localparam logic [3:0] R4 = {2{2'b01}};
endpackage
module top import pk::*; (input logic [31:0] sig, output logic [63:0] z);
  for (genvar i = 0; i < 2; i++) begin : g
    logic [1:0] y;
    assign y = sig[R4 +: 2];
  end
  assign z = 64'b0;
endmodule
