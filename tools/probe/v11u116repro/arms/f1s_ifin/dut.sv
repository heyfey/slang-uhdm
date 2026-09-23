module dut ();
  parameter int unsigned P = 32'h00000FFF;
  logic [31:0] a [2];
  logic [31:0] o [2];
  if (1) begin : gi
    for (genvar c = 0; c < 2; c++) begin : g
      assign o[c] = a[c] & ~P;
    end
  end
endmodule
