// § genCaFoldTsChainNamed169
module dut ();
  parameter logic [7:0] P = 8'h5;
  logic [31:0] a [2];
  logic [31:0] o [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = a[c] & P;
    assign o[c] = P;
  end
endmodule
