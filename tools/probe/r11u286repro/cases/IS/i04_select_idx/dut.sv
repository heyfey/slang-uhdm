// § foldIntTsSignedKwTrim286 — constant slot: int signed parameter in a select index and part-select bound
module dut ();
  parameter int signed P = 32'h00000FFF;
  logic [63:0] a [2];
  logic o2 [2];
  logic [3:0] o3 [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o2[c] = a[c][P % 32];
    assign o3[c] = a[c][P % 8 +: 4];
  end
endmodule
