// § genCaFoldTsChainNamed169
module dut (input logic [31:0] a [2], output logic [31:0] o [2]);
  localparam int L = 3;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = a[c] & L;
  end
endmodule
