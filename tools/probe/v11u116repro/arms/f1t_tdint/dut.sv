module dut ();
  typedef int unsigned u32_t;
  parameter u32_t P = 32'h00000FFF;
  logic [63:0] a [2];
  logic [63:0] o1 [2];
  logic o2 [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o1[c] = a[c] & P;
    assign o2[c] = a[c][P % 32];
  end
endmodule
