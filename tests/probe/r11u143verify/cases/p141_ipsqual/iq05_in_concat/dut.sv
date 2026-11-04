// § ipsQualBaseRangeSpan141v
// case iq05: a qualified indexed part-select nested in a concatenation of a parameter default
package p;
  parameter logic [15:0] A = 16'h1234;
  parameter int K = 2;
endpackage
module top #(parameter logic [7:0] P = {p::A[0 +: 4], 4'h0}) (output logic [7:0] o);
  assign o = P;
endmodule
