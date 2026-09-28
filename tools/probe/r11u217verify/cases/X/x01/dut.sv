// § genConnTrailSelChain205 § elabIfArrIdxChainName205 — r11u217 x01: an interface-ARRAY element's member bit-select as a generate-scope instance connection (`.x(b[k].v[1])`) beside a literal-driven interface-array element target in the same loop
interface bi;
  logic w;
  logic [1:0] v;
endinterface
module leaf (input logic x, output logic y);
  assign y = x;
endmodule
module dut (input logic [1:0] i, output logic [1:0] o, output logic p);
  bi b[2]();
  for (genvar k = 0; k < 2; k++) begin : g
    assign b[k].w = 1'b1;
    assign b[k].v = i;
    leaf u (.x(b[k].v[1]), .y(o[k]));
  end
  assign p = b[0].w;
endmodule
