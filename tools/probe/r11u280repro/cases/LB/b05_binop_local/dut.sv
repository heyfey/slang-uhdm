// § genLoopDirectBoundPaCopy280
// the select as a binary operand under a generate-local left side
module top (input logic [31:0] sig, output logic [1:0] z);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    logic [1:0] y;
    assign y = sig[R4 +: 2] | 2'b01;
  end
  assign z = g[1].y;
endmodule
