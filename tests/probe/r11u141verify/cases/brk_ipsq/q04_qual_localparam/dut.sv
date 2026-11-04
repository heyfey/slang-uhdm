// § paramIdxPartSelWholeSpan131
// case q04: package-qualified base in a body localparam
package p;
  parameter logic [15:0] A = 16'hABCD;
  parameter int K = 4;
endpackage
module top(output logic [3:0] o);
  localparam logic [3:0] L = p::A[4 +: 4];
  assign o = L;
endmodule
