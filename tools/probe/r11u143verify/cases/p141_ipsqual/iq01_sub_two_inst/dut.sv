// § ipsQualBaseRangeSpan141v
// case iq01: qualified base in a sub-module parameter default; one instance default, one overridden
package p;
  parameter logic [15:0] A = 16'h1234;
  parameter int K = 2;
endpackage
module sub #(parameter logic [3:0] P = p::A[8 +: 4]) (output logic [3:0] o);
  assign o = P;
endmodule
module top(output logic [3:0] o1, output logic [3:0] o2);
  sub u1(.o(o1));
  sub #(.P(4'h7)) u2(.o(o2));
endmodule
