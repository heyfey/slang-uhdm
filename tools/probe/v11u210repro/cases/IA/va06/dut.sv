// § elabIfArrIdxChainName205 — va06 (v11u210 break probe): a MODULE-INSTANCE array's net targeted hierarchically with a literal right side from a for-generate (not an interface array)
module child(output logic q);
  wire w;
  assign q = w;
endmodule
module dut(output logic [1:0] q);
  child c[2] (.q(q));
  for (genvar j = 0; j < 2; j++) begin : k
    assign c[j].w = 1'b0;
  end
endmodule
