// § anonAggElemKeywordTs247
package p;
  typedef struct { integer gv [2]; time tv [2]; longint unsigned lu [2]; bit signed [3:0] bs [2]; reg [1:0] rv [2]; } s_t;
endpackage
module top(input logic [7:0] a, output logic [7:0] o);
  p::s_t v;
  assign v.bs[0] = a[3:0];
  assign o = {4'b0, v.bs[0]};
endmodule
