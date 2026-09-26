// § ppBasedLitWsAfter166 § genCaFoldTsChainNamed169 § ppOutputCol166
`define MSK 8'h 0F
module dut (input logic [7:0] a [2], output logic [7:0] o [2]);
  parameter logic [7:0] P = 8'd 9;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = (a[c] & `MSK) + P;
  end
endmodule
