// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a signed 2-D packed operand and a uwire target
module dut (output logic [7:0] o1, o2);
  logic signed [3:0][1:0] sx;
  wire [7:0] w1 = $size(sx);
  assign o1 = w1;
  wire [7:0] w2 = $size(sx, 2);
  assign o2 = w2;
endmodule
