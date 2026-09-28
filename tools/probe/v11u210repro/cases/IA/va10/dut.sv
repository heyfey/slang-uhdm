// § elabIfArrIdxChainName205 — va10 (v11u210 break probe): the literal right side of a NON-continuous assignment context: a net declaration assignment and a procedural always_comb in the for-generate drive the interface array (only the always_comb reaches the hier path)
interface bi;
  logic w;
  logic x;
endinterface
module dut(output logic o, output logic p);
  bi b[2]();
  for (genvar i = 0; i < 2; i++) begin : g
    wire k = 1'b1;
    always_comb b[i].x = 1'b0;
    assign b[i].w = k;
  end
  assign o = b[1].w;
  assign p = b[0].x;
endmodule
