// § genLoopDirectBoundPaCopy280
// concatenation and hex-literal values as part-select bounds
module top (input logic [31:0] sig, output logic [3:0] o [2]);
  localparam logic [3:0] C4 = {2'b01, 2'b10};
  localparam logic [3:0] H4 = 4'hA;
  localparam logic [3:0] L0 = {1'b0, 3'b011};
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = {sig[C4 +: 2], sig[H4 : L0 + 4'd0]};
  end
endmodule
