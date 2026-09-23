module dut ();
  parameter int unsigned P = 32'h00000FFF;
  logic [31:0] a [2][2];
  logic [31:0] o [2][2];
  for (genvar c = 0; c < 2; c++) begin : g
    for (genvar d = 0; d < 2; d++) begin : h
      assign o[c][d] = a[c][d] & ~P;
    end
  end
endmodule
