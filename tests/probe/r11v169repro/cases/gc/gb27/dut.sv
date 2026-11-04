// § genCaFoldTsChainNamed169
module dut (input logic [31:0] m [2][8], output logic [31:0] o [2]);
  parameter int P = 6;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = m[c][P] | m[c][P - 1];
  end
endmodule
