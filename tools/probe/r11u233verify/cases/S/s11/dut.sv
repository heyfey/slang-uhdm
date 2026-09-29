// § parseViewSizeExprEval228 § pvSizeNoElemDeclines228v — the dimension a genvar in a generate-for block ($size(m, i))
module dut (output logic [7:0] o [3]);
  logic [3:0] m [5][6];
  for (genvar i = 1; i <= 3; i++) begin : g
    wire [7:0] w = $size(m, i);
    assign o[i-1] = w;
  end
endmodule
