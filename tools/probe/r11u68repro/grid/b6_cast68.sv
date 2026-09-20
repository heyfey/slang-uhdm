// r11u68 arm b6 — THE CAST TARGET TABLE.  `ExprEval::reduceExpr`'s vpiCastOp
// arm (UHDM/templates/ExprEval.cpp:4185-4314) folds a cast ONLY when the
// target typespec is int / long_int / bit / short_int / integer / enum; every
// other target leaves the op67 standing, `get_uvalue` refuses it and the
// operand walk returns.  Same bail detector (controls 8 = completed, 64 = bailed).
package qg;
  localparam int K = 6;
  localparam logic [7:0] P8 = 8'd12;
  typedef bit [7:0]   mb8_t;
  typedef logic [7:0] ml8_t;
  typedef bit         mb1_t;
  typedef struct packed { logic [7:0] p; logic [7:0] c1; logic [7:0] c2; } gt_t;
  localparam gt_t G_plain  = '{p: 3,            c1: K + 1, c2: K + 1};
  localparam gt_t G_mb8    = '{p: mb8_t'(7),    c1: K + 1, c2: K + 1};
  localparam gt_t G_ml8    = '{p: ml8_t'(7),    c1: K + 1, c2: K + 1};
  localparam gt_t G_mb1    = '{p: mb1_t'(1),    c1: K + 1, c2: K + 1};
  localparam gt_t G_szK    = '{p: 8'(K),        c1: K + 1, c2: K + 1};
  localparam gt_t G_szP8   = '{p: 8'(P8),       c1: K + 1, c2: K + 1};
  localparam gt_t G_reg    = '{p: reg'(1),      c1: K + 1, c2: K + 1};
  localparam gt_t G_time   = '{p: time'(7),     c1: K + 1, c2: K + 1};
  localparam gt_t G_byteu  = '{p: byte'(7),     c1: K + 1, c2: K + 1};
  localparam gt_t G_intu   = '{p: int'(K),      c1: K + 1, c2: K + 1};
endpackage
module b6_cast68 #(parameter qg::gt_t C_plain = qg::G_plain,
                   parameter qg::gt_t C_mb8   = qg::G_mb8,
                   parameter qg::gt_t C_ml8   = qg::G_ml8,
                   parameter qg::gt_t C_mb1   = qg::G_mb1,
                   parameter qg::gt_t C_szK   = qg::G_szK,
                   parameter qg::gt_t C_szP8  = qg::G_szP8,
                   parameter qg::gt_t C_reg   = qg::G_reg,
                   parameter qg::gt_t C_time  = qg::G_time,
                   parameter qg::gt_t C_byteu = qg::G_byteu,
                   parameter qg::gt_t C_intu  = qg::G_intu)
                  (output logic [31:0] y0, output logic [31:0] y1,
                   output logic [31:0] y2, output logic [31:0] y3,
                   output logic [31:0] y4, output logic [31:0] y5,
                   output logic [31:0] y6, output logic [31:0] y7,
                   output logic [31:0] y8, output logic [31:0] y9);
  assign y0 = {C_plain.p, C_plain.c1, C_plain.c2};
  assign y1 = {C_mb8.p,   C_mb8.c1,   C_mb8.c2};
  assign y2 = {C_ml8.p,   C_ml8.c1,   C_ml8.c2};
  assign y3 = {C_mb1.p,   C_mb1.c1,   C_mb1.c2};
  assign y4 = {C_szK.p,   C_szK.c1,   C_szK.c2};
  assign y5 = {C_szP8.p,  C_szP8.c1,  C_szP8.c2};
  assign y6 = {C_reg.p,   C_reg.c1,   C_reg.c2};
  assign y7 = {C_time.p,  C_time.c1,  C_time.c2};
  assign y8 = {C_byteu.p, C_byteu.c1, C_byteu.c2};
  assign y9 = {C_intu.p,  C_intu.c1,  C_intu.c2};
endmodule
