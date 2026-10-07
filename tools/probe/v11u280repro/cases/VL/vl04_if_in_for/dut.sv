// § genLoopDirectBoundPaCopy280
// the bound in an if-generate nested inside a for-generate and a for inside an if
module top #(parameter int M = 1) (input logic [31:0] sig, output logic [1:0] o [2], output logic [1:0] p [2]);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 0) begin : gi
      assign o[i] = sig[R4 +: 2];
    end else begin : ge
      assign o[i] = sig[R4+1 : R4];
    end
  end
  if (M == 1) begin : gm
    for (genvar j = 0; j < 2; j++) begin : gf
      assign p[j] = sig[R4 +: 2];
    end
  end
endmodule
