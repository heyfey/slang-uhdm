// § anonAggElemKeywordTs247
package p;
  typedef struct { int iv [2]; byte bv [2]; logic [3:0] lv [2]; } s_t;
endpackage
module top(input logic [7:0] a, output logic [7:0] o);
  p::s_t v;
  assign v.bv[0] = a;
  assign o = v.bv[0];
endmodule
