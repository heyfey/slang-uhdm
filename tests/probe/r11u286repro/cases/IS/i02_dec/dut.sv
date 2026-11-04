// § foldIntTsSignedKwTrim286 — int signed parameter, decimal literal
module dut ();
  parameter int signed P = 4095;
  logic [63:0] a [2];
  logic [63:0] o1 [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o1[c] = a[c] & P;
  end
endmodule
