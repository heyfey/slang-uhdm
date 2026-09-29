// § ifArrElemLitCaFresh225 — a comma list
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(output logic o);
  localparam int K = 1;
  bi b[2]();
  assign b[K].w = 1'b1, b[0].v = 4'h2;
  assign o = b[1].w;
endmodule
