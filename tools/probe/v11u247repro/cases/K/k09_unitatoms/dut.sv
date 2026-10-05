// § anonAggElemKeywordTs247
typedef byte sb_t [2];
typedef byte unsigned ub_t [2];
typedef shortint unsigned us_t [2];
typedef longint ls_t [2];
typedef integer unsigned iu_t [2];
typedef int unsigned nu_t [2];
module top(input logic [3:0] a, output logic [3:0] o);
  sb_t b; ub_t c; us_t d; ls_t e; iu_t f; nu_t g;
  assign b[0] = {a, a}; assign b[1] = 0;
  assign c[0] = {a, a}; assign c[1] = 0;
  assign d[0] = a; assign d[1] = 0;
  assign e[0] = a; assign e[1] = 0;
  assign f[0] = a; assign f[1] = 0;
  assign g[0] = a; assign g[1] = 0;
  assign o = b[0][3:0] ^ c[0][3:0] ^ d[0][3:0] ^ e[0][3:0] ^ f[0][3:0] ^ g[0][3:0];
endmodule
