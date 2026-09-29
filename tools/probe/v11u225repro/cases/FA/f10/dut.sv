// § ifArrElemLitCaFresh225 — fresh: one module instantiated twice with different selector parameters
interface bi;
  logic w;
endinterface
module m #(parameter int K = 0) (output logic o);
  bi b[2]();
  assign b[K].w = 1'b1;
  assign o = b[K].w;
endmodule
module dut(output logic [1:0] o);
  m #(.K(0)) u0(.o(o[0]));
  m #(.K(1)) u1(.o(o[1]));
endmodule
