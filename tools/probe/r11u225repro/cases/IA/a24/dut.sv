// § ifArrElemLitCaFresh225 — a second file declaring the same shape (args)
interface bi;
  logic w;
endinterface
module dut(output logic o);
  localparam int K = 1;
  bi b[2]();
  assign b[K].w = 1'b1;
  sub2 s();
  assign o = b[1].w;
endmodule
