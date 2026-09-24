// pt23.sv — the UNPACKED-ARRAY RANGE bound's constType.  Frontier after this
// pass's first three laws: ibex_core.sv:254 `pmp_cfg_t csr_pmp_cfg
// [PMPNumRegions];` where `parameter int unsigned PMPNumRegions = 4` is
// overridden to 16.  The array_var's range holds `op=11 (sub)` whose folded
// operand golden encodes UINT:16 ct=9 and we encode INT:16 ct=7, both size 64.
// Rows: an UNSIGNED int parameter (the corpus shape), a plain SIGNED `int`
// parameter, an untyped `parameter`, and a LOCALPARAM of each — over a struct
// element (array_var) and a logic element (array_net) so the two container
// kinds are separated.
typedef enum logic [1:0] { M_OFF, M_TOR, M_NA4, M_NAPOT } mode_e;
typedef struct packed { logic lock; mode_e mode; logic f; } cfg_t;

module pt23_child #(
    parameter int unsigned NU = 4,
    parameter int          NS = 4,
    parameter              NP = 4,
    parameter int unsigned ND = 8
) (
    input  logic clk_i,
    output logic [1:0] y_o,
    output logic [1:0] gy_o
);
  localparam int unsigned LU = 8;
  localparam int unsigned LR = ND;
  localparam int unsigned LM = ND * 2;
  localparam int          LS = 8;

  cfg_t        a_nu [NU];
  cfg_t        a_ns [NS];
  cfg_t        a_np [NP];
  cfg_t        a_nd [ND];
  cfg_t        a_lu [LU];
  cfg_t        a_lr [LR];
  cfg_t        a_lm [LM];
  cfg_t        a_ls [LS];
  logic [33:0] n_nu [NU];
  logic [33:0] n_lu [LU];

  assign y_o = {1'b0,a_nu[0].f} ^ {1'b0,a_ns[0].f} ^ {1'b0,a_np[0].f} ^ {1'b0,a_nd[0].f} ^ {1'b0,a_lu[0].f} ^ {1'b0,a_lr[0].f} ^ {1'b0,a_lm[0].f} ^ {1'b0,a_ls[0].f} ^
               n_nu[0][1:0] ^ n_lu[0][1:0];
  // The corpus's DEEPEST row of this family is in a GEN SCOPE:
  // ibex_cs_registers.sv:740 `pmp_cfg_t pmp_cfg [PMPNumRegions];` inside
  // `g_pmp_registers`, where the same overridden parameter sizes the dim.
  if (NU > 1) begin : gen_arr
    cfg_t        g_nu [NU];
    logic [33:0] g_nn [NU];
    cfg_t        g_lu [LU];
    assign gy_o = {1'b0,g_nu[0].f} ^ g_nn[0][1:0] ^ {1'b0,g_lu[0].f};
  end
endmodule

// The corpus override is TWO levels deep and the inner override VALUE is a
// REF to the middle module's own parameter, never a literal:
//   top_earlgrey  .PMPNumRegions(16)          -> rv_core_ibex
//   rv_core_ibex  .PMPNumRegions(PMPNumRegions) -> ibex_core
module pt23_mid #(
    parameter int unsigned NU = 4,
    parameter int          NS = 4,
    parameter              NP = 4
) (
    input  logic clk_i,
    output logic [1:0] y_o,
    output logic [1:0] gy_o
);
  pt23_child #(.NU(NU), .NS(NS), .NP(NP)) u_c (.clk_i, .y_o, .gy_o);
endmodule

module pt23 (
    input  logic clk_i,
    output logic [1:0] y_o,
    output logic [1:0] gy_o
);
  pt23_mid #(.NU(16), .NS(16), .NP(16)) u_m (.clk_i, .y_o, .gy_o);
endmodule
