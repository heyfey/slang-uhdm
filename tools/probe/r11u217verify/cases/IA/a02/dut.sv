// § elabIfArrIdxExprChainName210 — r11u217 a02: expression indices through a module parameter (`b[i+P].w`, `b[P*i].w`) and genvar arithmetic, with literal right sides, in a for-generate
interface bi;
  logic w;
endinterface
module dut #(parameter int P = 2) (output logic o);
  bi b[8]();
  for (genvar i = 0; i < 2; i++) begin : g
    assign b[i+P].w = 1'b1;
    assign b[P*i+5].w = 1'b0;
    assign b[2*i].w = 1'b1;
  end
  assign b[1].w = 1'b0;
  assign b[3].w = 1'b0;
  assign b[7].w = 1'b1;
  assign o = b[2].w;
endmodule
