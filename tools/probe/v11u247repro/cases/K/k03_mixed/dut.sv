// § anonAggElemKeywordTs247
typedef bit [1:0] u2_t [2][3];
typedef logic [1:0] l2_t [2];
typedef reg [1:0] r2_t [2];
typedef integer ig_t [2];
typedef time tm_t [2];
typedef longint ln_t [2];
module top(input logic [1:0] a, output logic [1:0] o);
  u2_t t;
  l2_t l;
  r2_t r;
  ig_t g;
  tm_t m;
  ln_t n;
  assign t[0][0] = a;
  assign l[0] = a;
  assign r[0] = ~a;
  assign g[0] = a;
  assign m[0] = a;
  assign n[0] = a;
  assign o = t[0][0] ^ l[0] ^ r[0] ^ g[0][1:0] ^ m[0][1:0] ^ n[0][1:0];
endmodule
