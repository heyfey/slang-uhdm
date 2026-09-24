// § paramIdxPartSelWholeSpan131
// case q09: package-qualified base as an interface parameter default
package p;
  parameter logic [15:0] A = 16'hABCD;
  parameter int K = 4;
endpackage
interface ifc #(parameter logic [3:0] P = p::A[0 +: 4]);
  logic [3:0] d;
  assign d = P;
endinterface
module top(output logic [3:0] o);
  ifc u();
  assign o = u.d;
endmodule
