// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a dynamic-then-fixed operand (int dq [][3]), both argument forms
module dut (output logic [7:0] o1, o2);
  int dq [][3];
  wire [7:0] w1 = $size(dq);
  assign o1 = w1;
  wire [7:0] w2 = $size(dq, 2);
  assign o2 = w2;
endmodule
