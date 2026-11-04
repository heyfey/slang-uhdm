// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — reg element and a signed narrow target
module dut (output logic [7:0] o1, o2);
  reg [3:0] rg [2][3];
  wire [7:0] w1 = $size(rg);
  assign o1 = w1;
  wire [7:0] w2 = $size(rg, 3);
  assign o2 = w2;
endmodule
