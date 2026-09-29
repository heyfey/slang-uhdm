// § ifArrElemLitCaFresh225 — r11u220 IA/i06 reproduced (r11u220 decode, no law there)
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module sub(output logic o);
  localparam int K = 0;
  bi b[2]();
  assign b[K].w = 1'b0;
  assign o = b[0].w;
endmodule
module dut(output logic o);
  sub s(.o(o));
endmodule
