module dut ();
  parameter int unsigned P = 'hFFF;
  logic [63:0] a [2];
  logic [63:0] o1 [2];
  logic o2 [2];
  logic [63:0] o3 [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o1[c] = a[c] & P;
    assign o2[c] = a[c] == P;
    assign o3[c] = P;
  end
endmodule
