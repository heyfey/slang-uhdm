// § ifArrElemLitCaFresh225 — fresh: a package localparam selector
package p;
  localparam int K = 1;
endpackage
interface bi;
  logic w;
endinterface
module dut(output logic o);
  bi b[2]();
  assign b[p::K].w = 1'b1;
  assign o = b[1].w;
endmodule
