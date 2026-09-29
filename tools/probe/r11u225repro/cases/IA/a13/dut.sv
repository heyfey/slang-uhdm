// § ifArrElemLitCaFresh225 — the module instantiated twice
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module sub(output logic o);
  localparam int K = 1;
  bi b[2]();
  assign b[K].w = 1'b1;
  assign o = b[1].w;
endmodule
module dut(output logic o1, output logic o2);
  sub u1(.o(o1));
  sub u2(.o(o2));
endmodule
