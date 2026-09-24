// § ipsQualBaseRangeSpan141v
// case iq02: qualified base with an operation start index, body localparam
package p;
  parameter logic [15:0] A = 16'h1234;
  parameter int K = 2;
endpackage
module top(output logic [3:0] o);
  localparam logic [3:0] L = p::A[2*2 +: 4];
  assign o = L;
endmodule
