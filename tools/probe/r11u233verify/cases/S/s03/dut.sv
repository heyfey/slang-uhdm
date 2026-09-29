// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a queue-then-fixed operand (int qf [$][2]), both argument forms
module dut (output logic [7:0] o1, o2);
  int qf [$][2];
  wire [7:0] w1 = $size(qf);
  assign o1 = w1;
  wire [7:0] w2 = $size(qf, 2);
  assign o2 = w2;
endmodule
