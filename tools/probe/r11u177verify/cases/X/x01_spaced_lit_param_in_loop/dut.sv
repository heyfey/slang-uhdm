// § ppBasedLitWsAfter166 § genCaFoldTsChainNamed169
module dut (input logic [7:0] a [2], output logic [7:0] o [2], output logic [7:0] q [2]);
  parameter logic [7:0] P = 8'h 5;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = a[c] & P;
    assign q[c] = (a[c] ^ 8'h 3) | P;
  end
endmodule
