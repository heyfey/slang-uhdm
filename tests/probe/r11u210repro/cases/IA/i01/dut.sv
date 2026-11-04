// § elabIfArrIdxChainName205 — i01: literal right sides in every form (parenthesized, sized, unbased '1, decimal) on interface-array element targets in a for-generate
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(output logic o, output logic [3:0] p);
  bi b[4]();
  for (genvar i = 0; i < 2; i++) begin : g
    assign b[i].w = (1'b1);
    assign b[i].v = '1;
  end
  for (genvar j = 2; j < 4; j++) begin : h
    assign b[j].w = 1;
    assign b[j].v = 4'd5;
  end
  assign o = b[0].w;
  assign p = b[3].v;
endmodule
