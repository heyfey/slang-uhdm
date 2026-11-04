// § genLoopDirectBoundPaCopy280
// a decimal int localparam (the c9 arm: unchanged control)
module top (input logic [31:0] sig, output logic [63:0] z);
  localparam int R4 = 5;
  for (genvar i = 0; i < 2; i++) begin : g
    logic [1:0] y;
    assign y = sig[R4 +: 2];
  end
  assign z = 64'b0;
endmodule
