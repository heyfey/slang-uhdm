// § elabIfArrIdxChainName205 — va03 (v11u210 break probe): the interface-array path in a CONCATENATION left side with a literal right side, and a parameter inside the expression index (§ elabIfArrIdxExprChainName210)
interface bi;
  logic w;
  logic x;
endinterface
module dut(output logic p);
  localparam int OFF = 1;
  bi b[4]();
  for (genvar i = 0; i < 2; i++) begin : g
    assign {b[i].w, b[i].x} = 2'b10;
    assign b[i+OFF+1].x = 1'b1;
  end
  assign p = b[3].x ^ b[0].w;
endmodule
