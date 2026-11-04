// § foldIntTsSignedKwTrim286 — control: int unsigned and plain int keep their spans
module dut ();
  parameter int unsigned P = 32'h00000FFF;
  parameter int Q = 5;
  logic [63:0] a [2];
  logic [63:0] o1 [2];
  logic [63:0] o2 [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o1[c] = a[c] & P;
    assign o2[c] = a[c] & Q;
  end
endmodule
