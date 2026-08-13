// r10earl35 — THE SEPARATING GRID.
//
// The target and its SIBLING ON THE NEXT SOURCE LINE differ in TWO ways at
// once, so the corpus alone cannot name the law:
//
//   flash_mp.sv:21  input flash_ctrl_reg_pkg::..._mp_region_cfg_mreg_t
//                         [TotalRegions-1:0] region_cfgs_i   golden: NO netType
//   flash_mp.sv:22  input flash_ctrl_reg_pkg::..._mp_bank_cfg_mreg_t
//                         [NumBanks-1:0]     bank_cfgs_i     golden: vpiNetType 1
//
//   candidate (a) STRUCT FLATNESS: region_cfg_mreg_t's members are all
//                 `struct packed {...}` (NESTED); bank_cfg_mreg_t has one
//                 plain `logic q` (FLAT).
//   candidate (b) DIMENSION SOURCE: TotalRegions is a module LOCALPARAM
//                 (derived: MpRegions+1); NumBanks is a module PARAMETER.
//
// The `*_lp` / `*_p` cells below cross flatness against dimension source so
// exactly one candidate can survive.
package e35_pkg;
  typedef struct packed { logic [7:0] q; } flat_t;

  typedef struct packed {
    struct packed { logic       q; } a;
    struct packed { logic [8:0] q; } b;
  } nest_t;

  typedef struct packed { logic [1:0] q; } inner_t;
  // a packed-ARRAY-of-struct MEMBER (the arm hasStructFieldMember already had)
  typedef struct packed { inner_t [3:0] arr; logic q; } arrm_t;
  // an ATOM member (integer) and an ENUM member — the OTHER un-descended
  // predicate at the same call site
  typedef struct packed { integer i; logic q; } atom_t;
  typedef enum logic [1:0] { E0, E1, E2, E3 } e_t;
  typedef struct packed { e_t e; logic q; } enumm_t;

  // the packed dimension carried by the TYPEDEF instead of the declaration
  typedef flat_t [3:0] flatarr_t;
  typedef nest_t [3:0] nestarr_t;
endpackage

module e35_dut #(
  parameter  int P          = 4,
  localparam int LP         = 4
) (
  input clk_i,

  // ---- no packed dimension at all (the already-landed baseline) ----
  input  e35_pkg::flat_t                n_flat,
  input  e35_pkg::nest_t                n_nest,
  input  e35_pkg::arrm_t                n_arrm,
  input  e35_pkg::atom_t                n_atom,
  input  e35_pkg::enumm_t               n_enum,

  // ---- packed dimension AT THE DECLARATION, literal bound ----
  input  e35_pkg::flat_t  [3:0]         d_flat,
  input  e35_pkg::nest_t  [3:0]         d_nest,   // THE WITNESS shape
  input  e35_pkg::arrm_t  [3:0]         d_arrm,
  input  e35_pkg::atom_t  [3:0]         d_atom,
  input  e35_pkg::enumm_t [3:0]         d_enum,

  // ---- THE SEPARATING PAIR: flatness x dimension-source ----
  input  e35_pkg::flat_t  [LP-1:0]      x_flat_lp,  // FLAT  + LOCALPARAM dim
  input  e35_pkg::nest_t  [P-1:0]       x_nest_p,   // NEST  + PARAMETER  dim
  input  e35_pkg::flat_t  [P-1:0]       x_flat_p,   // FLAT  + PARAMETER  dim
  input  e35_pkg::nest_t  [LP-1:0]      x_nest_lp,  // NEST  + LOCALPARAM dim

  // ---- the dimension carried by the TYPEDEF ----
  input  e35_pkg::flatarr_t             t_flat,
  input  e35_pkg::nestarr_t             t_nest,

  // ---- TWO packed dimensions at the declaration ----
  input  e35_pkg::flat_t  [3:0][1:0]    q_flat,
  input  e35_pkg::nest_t  [3:0][1:0]    q_nest,

  // ---- OUTPUT direction ----
  output e35_pkg::flat_t  [3:0]         o_flat,
  output e35_pkg::nest_t  [3:0]         o_nest,

  // ---- INOUT direction ----
  inout  e35_pkg::nest_t  [3:0]         b_nest,

  // ---- an explicit `wire` keyword on the same shape ----
  input  wire e35_pkg::nest_t [3:0]     w_nest
);
  // ---- BODY nets (non-port) of the same shapes ----
  e35_pkg::flat_t [3:0] l_flat;
  e35_pkg::nest_t [3:0] l_nest;
  e35_pkg::nest_t       l_nest0;

  assign o_flat = d_flat;
  assign o_nest = d_nest;
  assign l_flat = d_flat;
  assign l_nest = d_nest;
  assign l_nest0 = n_nest;
endmodule

module e35_top;
  logic clk;
  e35_pkg::flat_t                n_flat;
  e35_pkg::nest_t                n_nest;
  e35_pkg::arrm_t                n_arrm;
  e35_pkg::atom_t                n_atom;
  e35_pkg::enumm_t               n_enum;
  e35_pkg::flat_t  [3:0]         d_flat;
  e35_pkg::nest_t  [3:0]         d_nest;
  e35_pkg::arrm_t  [3:0]         d_arrm;
  e35_pkg::atom_t  [3:0]         d_atom;
  e35_pkg::enumm_t [3:0]         d_enum;
  e35_pkg::flat_t  [3:0]         x_flat_lp;
  e35_pkg::nest_t  [3:0]         x_nest_p;
  e35_pkg::flat_t  [3:0]         x_flat_p;
  e35_pkg::nest_t  [3:0]         x_nest_lp;
  e35_pkg::flatarr_t             t_flat;
  e35_pkg::nestarr_t             t_nest;
  e35_pkg::flat_t  [3:0][1:0]    q_flat;
  e35_pkg::nest_t  [3:0][1:0]    q_nest;
  e35_pkg::flat_t  [3:0]         o_flat;
  e35_pkg::nest_t  [3:0]         o_nest;
  wire e35_pkg::nest_t [3:0]     b_nest;
  e35_pkg::nest_t  [3:0]         w_nest;

  e35_dut u_dut (
    .clk_i(clk),
    .n_flat(n_flat), .n_nest(n_nest), .n_arrm(n_arrm), .n_atom(n_atom),
    .n_enum(n_enum),
    .d_flat(d_flat), .d_nest(d_nest), .d_arrm(d_arrm), .d_atom(d_atom),
    .d_enum(d_enum),
    .x_flat_lp(x_flat_lp), .x_nest_p(x_nest_p), .x_flat_p(x_flat_p),
    .x_nest_lp(x_nest_lp),
    .t_flat(t_flat), .t_nest(t_nest),
    .q_flat(q_flat), .q_nest(q_nest),
    .o_flat(o_flat), .o_nest(o_nest), .b_nest(b_nest), .w_nest(w_nest)
  );
endmodule
