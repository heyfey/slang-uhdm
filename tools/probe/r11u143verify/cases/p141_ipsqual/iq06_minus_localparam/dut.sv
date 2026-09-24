// § ipsQualBaseRangeSpan141v
// case iq06: a qualified indexed part-select with -: in a body localparam
package p;
  parameter logic [15:0] A = 16'h1234;
  parameter int K = 2;
endpackage
module top(output logic [3:0] o);
  localparam logic [3:0] L = p::A[11 -: 4];
  assign o = L;
endmodule
