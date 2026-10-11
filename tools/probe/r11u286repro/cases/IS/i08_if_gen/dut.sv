// § foldIntTsSignedKwTrim286 — if-generate and process read (control for the other fold sites)
module dut ();
  parameter int signed P = 6;
  logic [63:0] a;
  logic [63:0] o1;
  logic [63:0] o2;
  if (P > 0) begin : g
    assign o1 = a & P;
    always_comb o2 = a | P;
  end
endmodule
