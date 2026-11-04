// § anonAggElemKeywordTs247
package p;
  typedef struct { bit [3:0] pair [2]; logic [1:0] l [2]; } s_t;
endpackage
module top(input logic [3:0] a, output logic [3:0] o);
  p::s_t v;
  assign v.pair[0] = a;
  assign v.pair[1] = ~a;
  assign v.l[0] = a[1:0];
  assign v.l[1] = a[3:2];
  assign o = v.pair[0] ^ v.pair[1];
endmodule
