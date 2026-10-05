// § anonAggElemKeywordTs247
package p;
  typedef bit [1:0] pr_t [4];
  typedef bit signed [3:0] ps_t [2];
  typedef byte bb_t [2];
  typedef int unsigned iu_t [2];
  typedef shortint ss_t [3];
endpackage
module top(input logic [1:0] a, output logic [3:0] o);
  import p::*;
  pr_t t;
  ps_t s;
  bb_t b;
  iu_t u;
  ss_t h;
  assign t[0] = a;
  assign t[1] = ~a;
  assign s[0] = {a, a};
  assign s[1] = 4'h0;
  assign b[0] = {4{a}};
  assign b[1] = 8'h1;
  assign u[0] = a;
  assign u[1] = 0;
  assign h[0] = a; assign h[1] = 0; assign h[2] = 1;
  assign o = {t[a[0]], s[0][1:0]} ^ b[0][3:0] ^ u[0][3:0] ^ h[0][3:0];
endmodule
