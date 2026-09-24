// § paramIdxPartSelWholeSpan131
// case q08: control: a module parameter base (the law's measured shape), same layout as q01
package p;
  parameter logic [15:0] A = 16'hABCD;
  parameter int K = 4;
endpackage
module sub #(parameter logic [15:0] A = 16'hABCD, parameter logic [3:0] P = A[11 -: 4]) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o);
  sub u(.o(o));
endmodule
