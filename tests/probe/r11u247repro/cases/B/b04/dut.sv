// § anonAggElemKeywordTs247
module top(input logic [1:0] a, output logic [1:0] o);
  typedef bit [1:0] mr_t [4];
  typedef struct { bit [1:0] q [2]; } ms_t;
  mr_t t;
  ms_t m;
  assign t[0] = a;
  assign m.q[0] = a;
  assign o = t[0] ^ m.q[0];
endmodule
