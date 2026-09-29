// § ifArrElemLitCaFresh225 — fresh: CRLF line endings
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(output logic o, output logic [3:0] q);
  localparam int K = 1;
  bi b[2]();
  assign b[K].w = 1'b1;
  assign b[K].v = 4'h9;
  assign o = b[K].w;
  assign q = b[K].v;
endmodule
