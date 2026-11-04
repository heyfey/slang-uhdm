// § genLoopDirectBoundPaCopy280
// a child instantiated in a for-generate, its own replication localparam as the bound
module kid (input logic [31:0] sig, output logic [1:0] o [2]);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = sig[R4 +: 2];
  end
endmodule
module top (input logic [31:0] sig, output logic [1:0] o [2][2]);
  for (genvar j = 0; j < 2; j++) begin : gt
    kid u (.sig(sig), .o(o[j]));
  end
endmodule
