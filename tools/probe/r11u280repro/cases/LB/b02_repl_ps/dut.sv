// § genLoopDirectBoundPaCopy280
// a replication-fold localparam as part-select bounds
module top (input logic [31:0] sig, output logic [63:0] z);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    logic [63:0] x3, x4;
    assign x3 = sig[R4+1 : R4];
    assign x4 = sig[R4 : 0];
  end
  assign z = 64'b0;
endmodule
