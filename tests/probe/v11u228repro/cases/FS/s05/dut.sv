// § parseViewSizeExprEval228 — nested generate if and case blocks
module dut #(parameter int K = 1) (output logic [7:0] o1, o2);
  bit [4:0][2:0] bp;
  if (K == 1) begin : ga
    case (K)
      1: begin : gc
        wire [7:0] w = $size(bp);
      end
    endcase
  end
  for (genvar i = 0; i < 1; i++) begin : gf
    if (1) begin : gi
      wire [7:0] w = $size(bp, 2);
    end
  end
  assign o1 = ga.gc.w; assign o2 = gf[0].gi.w;
endmodule
