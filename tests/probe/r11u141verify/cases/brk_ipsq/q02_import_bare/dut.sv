// § paramIdxPartSelWholeSpan131
// case q02: control: the package parameter imported in the module header, the base written bare
package p;
  parameter logic [15:0] A = 16'hABCD;
  parameter int K = 4;
endpackage
module sub import p::*; #(parameter logic [3:0] P = A[4 +: 4]) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o);
  sub u(.o(o));
endmodule
