// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — an associative-then-fixed operand (int af [int][2]), both argument forms
module dut (output logic [7:0] o1, o2);
  int af [int][2];
  wire [7:0] w1 = $size(af);
  assign o1 = w1;
  wire [7:0] w2 = $size(af, 2);
  assign o2 = w2;
endmodule
