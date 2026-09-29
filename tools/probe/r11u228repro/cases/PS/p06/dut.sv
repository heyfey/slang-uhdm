// § parseViewSizeExprEval228 — CRLF line endings
module dut (output logic [7:0] o1);
  bit [3:0][1:0] bp;
  wire [3:0] w1 = $size(bp);
  assign o1 = w1;
endmodule
