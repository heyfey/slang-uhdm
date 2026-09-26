// § genCaFoldTsChainNamed169
module dut (input logic [31:0] a [2], output logic [31:0] o [2]);
  parameter int P = 6;
  if (P > 1) begin : g
    assign o[0] = a[0] & P;
    assign o[1] = a[1][P] ? P : 0;
  end
endmodule
