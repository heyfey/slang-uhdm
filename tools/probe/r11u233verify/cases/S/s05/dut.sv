// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a fixed-then-associative operand (int fa [2][string]), the first dimension in both argument forms
module dut (output logic [7:0] o1, o2);
  int fa [2][string];
  wire [7:0] w1 = $size(fa);
  assign o1 = w1;
  wire [7:0] w2 = $size(fa, 1);
  assign o2 = w2;
endmodule
