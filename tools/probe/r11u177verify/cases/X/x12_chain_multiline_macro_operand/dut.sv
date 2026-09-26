// § genCaFoldTsChainNamed169 § ppOutputLine166 § ppOutputCol166
`define ANDP(x) \
  (x) & \
  P
module dut (input logic [31:0] a [2], output logic [31:0] o [2]);
  parameter int P = 6;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = `ANDP(a[c]) | (a[c] >> P);
  end
endmodule
