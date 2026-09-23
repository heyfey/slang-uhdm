module dut ();
  parameter integer P = 32'hFFF;
  logic [63:0] a [2];
  logic [63:0] o1 [2];
  logic o2 [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o1[c] = a[c] & P;
    assign o2[c] = a[c][P % 32];
  end
endmodule
