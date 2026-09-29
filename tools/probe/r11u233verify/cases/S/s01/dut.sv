// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — one-dimensional dynamic, queue and associative operands
module dut (output logic [7:0] o1, o2, o3);
  int d [];
  int q [$];
  int a [int];
  wire [7:0] w1 = $size(d);
  assign o1 = w1;
  wire [7:0] w2 = $size(q);
  assign o2 = w2;
  wire [7:0] w3 = $size(a);
  assign o3 = w3;
endmodule
