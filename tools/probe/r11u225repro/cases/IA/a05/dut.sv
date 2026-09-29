// § ifArrElemLitCaFresh225 — r11u220 IA/i05 reproduced (r11u220 decode, no law there)
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(output logic o);
  localparam int K = 1;
  bi b[2]();
  assign b[K].v[1] = 1'b1;
  assign o = b[0].w;
endmodule
