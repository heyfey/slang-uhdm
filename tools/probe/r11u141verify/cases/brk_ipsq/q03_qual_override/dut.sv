// § paramIdxPartSelWholeSpan131
// case q03: package-qualified base in a parameter override actual
package p;
  parameter logic [15:0] A = 16'hABCD;
  parameter int K = 4;
endpackage
module sub #(parameter logic [3:0] P = 4'h0) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o);
  sub #(.P(p::A[8 +: 4])) u(.o(o));
endmodule
