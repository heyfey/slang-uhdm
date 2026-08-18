// v65 ARM 4 — the DOTTED (hier_path) spelling, both emitter sites, plus the
// wide-value / negative / struct-typed origins.  MEASUREMENT ONLY.
package pa4;
  localparam int QW = 5;
  localparam int QB = 2;
  localparam logic [95:0] WIDE = 96'h1234_5678_9abc_def0_1234_5678;
  localparam int NEG = -3;
  localparam int BIG = 40;
endpackage

typedef struct packed { logic [63:0] f; logic [63:0] g; } st4_t;

module l4 (input logic [31:0] a_i, input logic b_i, output logic o_o);
  assign o_o = ^a_i ^ b_i;
endmodule

module a4_hier import pa4::*; (input st4_t st_i, input logic [127:0] d_i,
                               output logic [11:0] o_o);
  // dotted ips WIDTH / BASE (site 1: constant base)
  l4 u_hw (.a_i(st_i.f[0  +: QW]), .b_i(st_i.f[0]), .o_o(o_o[0]));
  l4 u_hb (.a_i(st_i.f[QB +: 32]), .b_i(st_i.f[0]), .o_o(o_o[1]));
  // dotted ips with an ARITHMETIC base (site 2: the base-select spelling)
  l4 u_ha (.a_i(st_i.g[QB*2 +: QW]), .b_i(st_i.g[0]), .o_o(o_o[2]));
  // dotted part-select bounds — the NEGATIVE CONTROL
  l4 u_hp (.a_i({27'b0, st_i.f[QW-1:QB]}), .b_i(st_i.f[0]), .o_o(o_o[3]));
  // dotted bit-select index
  l4 u_hi (.a_i(st_i.f[31:0]), .b_i(st_i.f[QB]), .o_o(o_o[4]));
  // WIDE / NEGATIVE / >32 origins in the plain ips
  l4 u_wd (.a_i(d_i[0   +: BIG]), .b_i(d_i[0]), .o_o(o_o[5]));
  l4 u_ng (.a_i(d_i[8+NEG +: 32]), .b_i(d_i[0]), .o_o(o_o[6]));
  // the same shapes in a cont_assign (must NOT move)
  logic [4:0] c1; logic [31:0] c2; logic [39:0] c3;
  assign c1 = st_i.f[0  +: QW];
  assign c2 = st_i.f[QB +: 32];
  assign c3 = d_i[0 +: BIG];
  assign o_o[11:7] = {^c1, ^c2, ^c3, WIDE[0], 1'b0};
endmodule
