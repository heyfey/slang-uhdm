// § ifArrElemLitCaFresh225 — a delayed assignment (not re-compiled by the law)
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(output logic o);
  localparam int K = 1;
  bi b[2]();
  assign #1 b[K].w = 1'b1;
  assign o = b[1].w;
endmodule
