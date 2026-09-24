// § ipsQualBaseRangeSpan141v
// case iq04: control, qualified base in a continuous assignment (not a constant context)
package p;
  parameter logic [15:0] A = 16'h1234;
  parameter int K = 2;
endpackage
module top(output logic [3:0] o);
  assign o = p::A[4 +: 4];
endmodule
