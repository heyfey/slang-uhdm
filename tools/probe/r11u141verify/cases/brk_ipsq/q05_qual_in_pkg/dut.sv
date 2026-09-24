// § paramIdxPartSelWholeSpan131
// case q05: package-qualified base in another package's parameter
package p;
  parameter logic [15:0] A = 16'hABCD;
  parameter int K = 4;
endpackage
package q;
  parameter logic [3:0] P = p::A[4 +: 4];
endpackage
module top(output logic [3:0] o);
  assign o = q::P;
endmodule
