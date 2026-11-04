// § ifArrElemLitCaFresh225 — fresh: the assignment in a header included by two modules
interface bi;
  logic w;
endinterface
module m1(output logic o);
  localparam int K = 1;
  bi b[2]();
`include "inc.svh"
  assign o = b[K].w;
endmodule
module m2(output logic o);
  localparam int K = 0;
  bi b[2]();
`include "inc.svh"
  assign o = b[K].w;
endmodule
module dut(output logic [1:0] o);
  m1 u1(.o(o[0]));
  m2 u2(.o(o[1]));
endmodule
