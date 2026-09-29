// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a net array operand (wire [3:0] na [3][2])
module dut (output logic [7:0] o1, o2, o3);
  wire [3:0] na [3][2];
  wire [7:0] w1 = $size(na);
  assign o1 = w1;
  wire [7:0] w2 = $size(na, 2);
  assign o2 = w2;
  wire [7:0] w3 = $size(na, 3);
  assign o3 = w3;
endmodule
