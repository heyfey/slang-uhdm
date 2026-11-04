// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — the dimension a parameter ($size(m, D))
module dut (output logic [7:0] o1, o2);
  localparam int D = 2;
  logic [3:0] m [5][6];
  wire [7:0] w1 = $size(m, D);
  assign o1 = w1;
  wire [7:0] w2 = $size(m, D + 1);
  assign o2 = w2;
endmodule
