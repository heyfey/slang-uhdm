// § genCaFoldTsChainNamed169
module dut ();
  parameter int P = 6;
  logic [31:0] a [2];
  logic [31:0] o [2];
  if (1) begin : gi
    assign o[0] = a[0] & P;
  end
endmodule
