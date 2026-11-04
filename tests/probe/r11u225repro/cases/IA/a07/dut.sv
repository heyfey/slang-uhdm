// § ifArrElemLitCaFresh225 — r11u220 IA/i07 reproduced (r11u220 decode, no law there)
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(input logic x, output logic o);
  enum logic [0:0] { E0 } e;
  bi b[2]();
  assign b[E0].w = x & 1'b1;
  assign o = b[0].w;
endmodule
