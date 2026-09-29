// § parseViewSizeExprEval228 — two files, the same declarator position in both
module dut (output logic [7:0] o1, o2);
  bit [3:0][1:0] bp;
  wire [7:0] w1 = $size(bp);
  other u (.o(o2));
  assign o1 = w1;
endmodule
