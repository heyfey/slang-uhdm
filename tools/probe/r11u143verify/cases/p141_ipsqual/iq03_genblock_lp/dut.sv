// § ipsQualBaseRangeSpan141v
// case iq03: qualified base in a generate-block localparam
package p;
  parameter logic [15:0] A = 16'h1234;
  parameter int K = 2;
endpackage
module top(output logic [7:0] o);
  if (1) begin : g
    localparam logic [7:0] L = p::A[0 +: 8];
    assign o = L;
  end
endmodule
