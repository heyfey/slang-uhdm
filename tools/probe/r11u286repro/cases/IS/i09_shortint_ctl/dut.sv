// § foldIntTsSignedKwTrim286 — control: shortint signed and longint signed parameters
module dut ();
  parameter longint signed P = 64'h3;
  logic [63:0] a [2];
  logic [63:0] o1 [2];
  for (genvar c = 0; c < 2; c++) begin : g
    assign o1[c] = a[c] & P;
  end
endmodule
