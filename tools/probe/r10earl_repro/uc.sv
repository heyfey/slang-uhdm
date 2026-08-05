// r10earl9 witness C — the BIGGEST remaining Earlgrey family:
//   "golden folded a declaration RANGE BOUND that reads a PACKAGE parameter
//    to a constant; we kept the ref_obj"
// 10+ heads, every one a module that WILDCARD-IMPORTS a *_reg_pkg and reads
// one of its `parameter int` members in a bound:
//   alert_handler:33:22 NAlerts (ANSI port)      hmac:25:22 NumAlerts (port)
//   rv_timer:27:10 N_HARTS (var)                 usbdev:140:10 NEndpoints (var)
//   rv_plic:41:36 NumTarget (port)               sha2:36:17 NumRound ($clog2)
//   flash_erase_ctrl:41:20 AddrW (localparam)    padring:15:20 NMioPads (param port)
//   pinmux:222:19 NDioPads (genvar loop bound)
//   tlul_adapter_sram:56:12 top_pkg::TL_SZW (QUALIFIED, struct member)
// § crossPkgRangeBoundFold already implements the QUALIFIED spelling for a
// MODULE PARAMETER's declared type; this witness asks which POSITIONS and
// which SPELLINGS golden actually substitutes.
package ucp;
  parameter int NA   = 3;
  parameter int NB   = 5;
  localparam int NC  = 7;
  parameter logic [7:0] ND = 8'd9;
endpackage

module uc
  import ucp::*;
#(
  // row A — a module PARAMETER PORT's declared type, UNQUALIFIED (padring)
  parameter logic [NA-1:0] PA = '1,
  // row B — the same, QUALIFIED (the landed § crossPkgRangeBoundFold shape)
  parameter logic [ucp::NA-1:0] PB = '1
) (
  input  logic clk_i,
  // row C — an ANSI PORT range bound, unqualified (alert_handler, hmac, rv_plic)
  input  logic [NA-1:0] c_i,
  // row D — an ANSI PORT range bound, qualified
  input  logic [ucp::NA-1:0] d_i,
  output logic o
);
  // row E — a VARIABLE declaration bound, unqualified (rv_timer, usbdev)
  logic [NB-1:0]        e_v;
  // row F — a VARIABLE declaration bound, qualified
  logic [ucp::NB-1:0]   f_v;
  // row G — a LOCALPARAM declared-type bound, unqualified (flash_erase_ctrl)
  localparam logic [NB-1:0] G_P = '0;
  // row H — a $clog2 ARGUMENT, unqualified (sha2)
  logic [$clog2(NB)-1:0] h_v;
  // row I — a package LOCALPARAM read (not a parameter), unqualified
  logic [NC-1:0]        i_v;
  // row J — a STRUCT MEMBER bound, qualified (tlul_adapter_sram)
  typedef struct packed {
    logic [ucp::NA-1:0] a;
    logic [NB-1:0]      b;
  } j_t;
  j_t j_v;
  // row K — a genvar for-loop BOUND, unqualified (pinmux)
  logic [7:0] k_v;
  for (genvar k = NA; k < 8; k++) begin : gen_k
    assign k_v[k] = 1'b0;
  end
  for (genvar k = 0; k < NA; k++) begin : gen_k2
    assign k_v[k] = 1'b1;
  end
  // row L — a TYPED (non-int) package parameter as a bound
  logic [ND-1:0]        l_v;

  assign o = clk_i ^ ^c_i ^ ^d_i ^ ^e_v ^ ^f_v ^ ^h_v ^ ^i_v ^ ^j_v ^ ^k_v
             ^ ^l_v ^ ^PA ^ ^PB ^ ^G_P;
endmodule
