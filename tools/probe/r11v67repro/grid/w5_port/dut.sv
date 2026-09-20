// w5_port -- PORTS (ANSI and non-ANSI), by direction x home x keyword.
package pk;
  typedef logic [1:0] cv_t;
  typedef reg   [1:0] cr_t;
endpackage
typedef logic [1:0] uv_t;
module w5
  import pk::*;
 (
  input  cv_t p01,
  output cv_t p02,
  inout  cv_t p03,
  input  wire cv_t p04,
  output wire cv_t p05,
  input  cr_t p06,
  input  uv_t p07,
  input  wire uv_t p08,
  input  logic [1:0] p09,
  input  wire logic [1:0] p10
);
  typedef logic [1:0] lv_t;
  typedef reg   [1:0] lr_t;
  lv_t p11;
  wire lv_t p12;
  assign p02 = p01;
  assign p11 = p09;
  assign p12 = p10;
endmodule
module w5b (p20, p21, p22, p23);
  import pk::*;
  typedef logic [1:0] lv_t;
  input  cv_t p20;
  output lv_t p21;
  input  wire cv_t p22;
  inout  wire lv_t p23;
  assign p21 = p20;
endmodule
module w5top;
  wire [1:0] a, b, c, d, e, f, g;
  w5  u5 (.p01(a), .p02(b), .p03(c), .p04(d), .p05(e), .p06(f), .p07(g),
          .p08(g), .p09(a), .p10(b));
  w5b u5b (.p20(a), .p21(b), .p22(c), .p23(d));
endmodule
