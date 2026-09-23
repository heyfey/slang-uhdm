module dut ();
  parameter int unsigned P = 32'h00000FFF;
  logic [31:0] a [2];
  logic [31:0] o [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = (c == 0) ? P : a[c];
    wire [31:0] w = a[c] | P;
  end
endmodule
