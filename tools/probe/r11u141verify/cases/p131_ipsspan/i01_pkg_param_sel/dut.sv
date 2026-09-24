// § paramIdxPartSelWholeSpan131
// case i01: indexed part-select of a package parameter, package-qualified
package p;
  parameter logic [15:0] A = 16'hABCD;
endpackage
module sub #(parameter logic [3:0] P = p::A[4 +: 4]) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o);
  sub u(.o(o));
endmodule
