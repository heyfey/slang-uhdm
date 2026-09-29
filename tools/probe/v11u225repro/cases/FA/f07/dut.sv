// § ifArrElemLitCaFresh225 — fresh: the assignment written by a macro
`define SETW(i, v) assign b[i].w = v;
interface bi;
  logic w;
endinterface
module dut(output logic [1:0] o);
  localparam int K = 1;
  bi b[2]();
  `SETW(K, 1'b1)
  `SETW(0, 1'b0)
  assign o = {b[1].w, b[0].w};
endmodule
