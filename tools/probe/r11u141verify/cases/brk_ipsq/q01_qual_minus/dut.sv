// § paramIdxPartSelWholeSpan131
// case q01: package-qualified base, -: select, module parameter default
package p;
  parameter logic [15:0] A = 16'hABCD;
  parameter int K = 4;
endpackage
module sub #(parameter logic [3:0] P = p::A[11 -: 4]) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o);
  sub u(.o(o));
endmodule
