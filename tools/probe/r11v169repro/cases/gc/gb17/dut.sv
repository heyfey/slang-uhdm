// § genCaFoldTsChainNamed169
module dut (input logic [31:0] a [2], output logic [31:0] o [2][2]);
  parameter int P = 6;
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      assign o[i][j] = a[j][P] ? (a[i] & P) : a[i];
    end
  end
endmodule
