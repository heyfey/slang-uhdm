// § genLoopDirectBoundPaCopy280
// two for-generate levels
module top (input logic [31:0] sig, output logic [63:0] z);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : ga
    for (genvar j = 0; j < 2; j++) begin : gb
      logic [1:0] y;
      assign y = sig[R4 +: 2];
    end
  end
  assign z = 64'b0;
endmodule
