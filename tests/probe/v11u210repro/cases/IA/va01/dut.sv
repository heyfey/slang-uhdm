// § elabIfArrIdxChainName205 — va01 (v11u210 break probe): a generate-block ARRAY (not an interface array) targeted hierarchically from another for-generate with literal right sides, beside a module instance array's net
module child(output logic q);
  wire w;
  assign q = w;
endmodule
module dut(output logic o, output logic p);
  for (genvar i = 0; i < 2; i++) begin : g
    logic a;
  end
  for (genvar i = 0; i < 2; i++) begin : h
    assign g[i].a = 1'b1;
  end
  logic [1:0] q;
  child c[2] (.q(q));
  for (genvar j = 0; j < 2; j++) begin : k
    assign c[j].w = 1'b0;
  end
  assign o = g[0].a;
  assign p = q[1];
endmodule
