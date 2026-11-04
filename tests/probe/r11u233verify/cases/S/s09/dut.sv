// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a typedef'd bit packed 2-D variable
module dut (output logic [7:0] o1, o2);
  typedef bit [3:0][1:0] bp_t;
  bp_t b;
  wire [7:0] w1 = $size(b);
  assign o1 = w1;
  wire [7:0] w2 = $size(b, 2);
  assign o2 = w2;
endmodule
