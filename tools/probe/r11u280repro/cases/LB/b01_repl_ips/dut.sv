// § genLoopDirectBoundPaCopy280
// a replication-fold localparam as an indexed part-select base and width in a for-generate
module top (input logic [31:0] sig, output logic [63:0] z);
  localparam logic [3:0] R4 = {2{2'b01}};
  localparam logic [1:0] W2 = {2{1'b1}};
  for (genvar i = 0; i < 2; i++) begin : g
    logic [63:0] x1, x2;
    assign x1 = sig[R4 +: 2];
    assign x2 = sig[4 +: W2];
  end
  assign z = 64'b0;
endmodule
