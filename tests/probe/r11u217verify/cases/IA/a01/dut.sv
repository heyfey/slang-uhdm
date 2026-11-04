// § elabIfArrIdxChainName205 — r11u217 a01: interface-array element targets with literal right sides at generate depths 1, 2 and 3 (for in for in for), indexed by the innermost and by an outer genvar
interface bi;
  logic w;
  logic x;
endinterface
module dut(output logic o, output logic p);
  bi b[8]();
  for (genvar i = 0; i < 2; i++) begin : g1
    assign b[i].x = 1'b0;
    for (genvar j = 0; j < 2; j++) begin : g2
      assign b[i+2].x = 1'b1;
      for (genvar k = 0; k < 2; k++) begin : g3
        assign b[k].w = 1'b1;
      end
    end
  end
  for (genvar m = 4; m < 8; m++) begin : h
    assign b[m].w = 1'b0;
    assign b[m].x = 1'b1;
  end
  assign b[2].w = 1'b0;
  assign b[3].w = 1'b1;
  assign o = b[0].w;
  assign p = b[5].x;
endmodule
