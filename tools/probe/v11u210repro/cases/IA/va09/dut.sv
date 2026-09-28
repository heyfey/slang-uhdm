// § elabIfArrIdxChainName205 — va09 (v11u210 break probe): a TWO-DIMENSIONAL interface array targeted with two genvar indices and a literal right side
interface bi;
  logic w;
endinterface
module dut(output logic o);
  bi b[2][2]();
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      assign b[i][j].w = 1'b0;
    end
  end
  assign o = b[1][0].w;
endmodule
