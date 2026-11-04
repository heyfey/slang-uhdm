// § foldIntTsSignedKwTrim286 — int signed in the parameter port list, macro-written default
`define DV 12
module dut #(parameter int signed P = `DV) (input logic [63:0] a [2], output logic [63:0] o1 [2]);
  for (genvar c = 0; c < 2; c++) begin : g
    assign o1[c] = a[c] + P;
  end
endmodule
