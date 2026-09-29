// § ifArrElemLitCaFresh225 — a qualified package enum constant as the selector
interface bi;
  logic w;
  logic [3:0] v;
endinterface
package p;
  typedef enum logic [0:0] {P0, P1} pe_t;
endpackage
module dut(output logic o);
  bi b[2]();
  assign b[p::P1].w = 1'b1;
  assign o = b[1].w;
endmodule
