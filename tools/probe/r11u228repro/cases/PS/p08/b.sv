// § parseViewSizeExprEval228 — two files (the second)
module other (output logic [7:0] o);
  bit [5:0][2:0] bp;
  wire [7:0] w1 = $size(bp);
  assign o = w1;
endmodule
