// § genLoopDirectBoundPaCopy280
// the select as a binary operand under a plain outside left side (keeps the select parent)
module top (input logic [31:0] sig, output logic [1:0] o [2]);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = sig[R4 +: 2] & 2'b11;
  end
endmodule
