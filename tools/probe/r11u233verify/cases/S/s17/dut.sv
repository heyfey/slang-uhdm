// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — chandle and event array operands
module dut (output logic [7:0] o1, o2);
  chandle ca [2];
  event ev [3];
  wire [7:0] w1 = $size(ca);
  assign o1 = w1;
  wire [7:0] w2 = $size(ev);
  assign o2 = w2;
endmodule
