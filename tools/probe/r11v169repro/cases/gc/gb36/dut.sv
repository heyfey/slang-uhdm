// § genCaFoldTsChainNamed169
module dut (input logic [31:0] a [4], output logic [31:0] o [4]);
  parameter int P = 1;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c + P + 1] = a[c] & P;
    assign o[c] = a[c];
  end
endmodule
