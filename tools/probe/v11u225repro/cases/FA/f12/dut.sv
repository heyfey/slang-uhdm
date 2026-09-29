// § ifArrElemLitCaFresh225 — fresh: a cast literal and an unsized decimal onto element members
interface bi;
  logic [7:0] v;
  int n;
endinterface
module dut(output logic [7:0] q, output int r);
  localparam int K = 1;
  bi b[2]();
  assign b[K].v = 8'(3);
  assign b[0].n = 42;
  assign q = b[K].v;
  assign r = b[0].n;
endmodule
