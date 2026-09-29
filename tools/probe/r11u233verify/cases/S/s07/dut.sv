// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — a typedef'd element (nib_t a [5]) in both argument forms
module dut (output logic [7:0] o1, o2);
  typedef logic [3:0] nib_t;
  nib_t a [5];
  wire [7:0] w1 = $size(a);
  assign o1 = w1;
  wire [7:0] w2 = $size(a, 2);
  assign o2 = w2;
endmodule
