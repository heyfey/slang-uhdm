// § elabIfArrIdxExprChainName210 — i02 (with § elabIfArrIdxChainName205): two-level generate (for inside for, if inside for) with literal right sides
interface bi;
  logic w;
endinterface
module dut(output logic o);
  bi b[4]();
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar k = 0; k < 2; k++) begin : q
      assign b[i*2+k].w = 1'b0;
    end
  end
  for (genvar m = 0; m < 1; m++) begin : r
    if (m == 0) begin : c
      assign b[m].w = 1'b1;
    end
  end
  assign o = b[1].w;
endmodule
