// § genCaFoldTsChainNamed169
module dut (input logic [31:0] a [2], output wire [31:0] o [2]);
  parameter int P = 6;
  for (genvar c = 0; c < 2; c++) begin : g
    wire w = a[c][P]; assign o[c] = {31'b0, w};
  end
endmodule
