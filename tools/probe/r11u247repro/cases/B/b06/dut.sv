// § anonAggElemKeywordTs247
typedef int ia_t [2];
typedef byte unsigned ba_t [3];
typedef shortint sa_t [2];
module top(input logic [7:0] a, output logic [7:0] o);
  ia_t i;
  ba_t b;
  sa_t s;
  assign b[0] = a;
  assign i[1] = 5;
  assign s[0] = 16'h3;
  assign o = b[0] ^ i[1][7:0] ^ s[0][7:0];
endmodule
