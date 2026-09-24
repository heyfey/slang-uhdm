module dut ();
  parameter int unsigned P = 32'h00000FFF;
  logic [31:0] a [4];
  logic [31:0] o [4];
  for (genvar c = 0; c < P % 4 + 1; c++) begin : g
    assign o[c] = a[c] & P;
  end
endmodule
