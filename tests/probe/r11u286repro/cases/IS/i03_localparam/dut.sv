// § foldIntTsSignedKwTrim286 — int signed localparam
module dut ();
  localparam int signed P = 7;
  logic [63:0] a [2];
  logic [63:0] o1 [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o1[c] = a[c] | P;
  end
endmodule
