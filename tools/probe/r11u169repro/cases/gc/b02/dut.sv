// § genCaFoldTsChainNamed169
module dut ();
  parameter int P = 6;
  logic [31:0] a [2];
  logic [31:0] o [2];
  for (genvar c = 0; c < 2; c++) begin : g
    if (c == 0) begin : t
      assign o[c] = a[c] & P;
    end else begin : e
      assign o[c] = a[c] | P;
    end
  end
endmodule
