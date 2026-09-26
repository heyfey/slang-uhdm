// § genCaFoldTsChainNamed169
module dut (input logic [31:0] a [2], output wire [31:0] o [2]);
  parameter int P = 6;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c][P] = a[c][0]; assign o[c][P-1:0] = '0; assign o[c][31:P+1] = '0;
  end
endmodule
