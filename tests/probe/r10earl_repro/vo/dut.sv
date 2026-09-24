// vo.sv — pass 12, ranked residue (7): THE SELECT-BOUND FOLD FAMILY (5 heads,
// the largest single-law class left in Earlgrey_0_1).  All five live in a
// module DEF listing (AllModules) and all five are part-selects whose bounds
// name parameters:
//   pwrmgr_fsm:99   pwr_rst_i.rst_lc_src_n[PowerDomains-1:1]
//                     golden `[2 - 1:1]`      — PACKAGE param folds, `-1` does not
//   flash_phy:66    flash_ctrl_i.addr[BankAddrW +: BankW]
//                     golden `[16+:1]`        — BOTH package params fold
//   dm_csrs:305     dmi_req_i.addr[$clog2(dm::ProgBufSize)-1:0]
//                     golden `[$clog2(5'h8) - 1:0]` — QUALIFIED package param
//                     folds to its OWN literal spelling, $clog2 and -1 do not
//   spi_device:159  reg2hw.rxf_addr.base.q[SDW+:SramAw]
//                     golden KEEPS BOTH symbolic — SramAw is a module
//                     PARAMETER PORT and SDW a module localparam (the MIRROR:
//                     we fold SramAw to 9)
// The 2x2x2 below separates (a) package vs module-scope parameter,
// (b) bare vs qualified spelling, (c) hier_path (member select) vs plain
// identifier base — line 65 of flash_phy is the plain-base twin of line 66
// and is NOT a head, so the base kind may matter.
package vop;
  parameter int PW = 2;
  parameter int BW = 16;
  localparam logic [4:0] LW = 5'h8;
endpackage

module voa import vop::*; #(
  parameter int MP = 9
) (
  input  logic [31:0] v_i,
  output logic        a_o, b_o, c_o, d_o, e_o, f_o, g_o, h_o
);
  typedef struct packed {
    logic [31:0] addr;
  } s_t;
  s_t st;
  assign st = '{addr: v_i};

  localparam int LP = 3;

  // PLAIN base (identifier), package parameter
  assign a_o = |v_i[PW-1:1];            // A  bare package param, range select
  assign b_o = |v_i[BW +: 1];           // B  bare package param, indexed +:
  assign c_o = |v_i[vop::PW-1:0];       // C  QUALIFIED package param

  // HIER_PATH base (struct member select), package parameter
  assign d_o = |st.addr[PW-1:1];        // D  bare package param
  assign e_o = |st.addr[BW +: 1];       // E  bare package param, indexed
  assign f_o = |st.addr[$clog2(vop::LW)-1:0]; // F  qualified inside $clog2

  // MODULE-SCOPE parameters (the spi_device mirror) — must stay symbolic
  assign g_o = |st.addr[LP +: MP];      // G  module localparam + param port
  assign h_o = |v_i[LP +: MP];          // H  the plain-base twin of G
endmodule

module votop;
  logic [31:0] v;
  logic a, b, c, d, e, f, g, h;
  voa u (.v_i(v), .a_o(a), .b_o(b), .c_o(c), .d_o(d),
         .e_o(e), .f_o(f), .g_o(g), .h_o(h));
endmodule
