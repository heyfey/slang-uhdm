// r10earl8 witness tl — ELAB (TopModules) parameter RANGE BOUND fold, the
// sram2tlul / jtag_mux pair (2 of the 8 TopModules heads, and they point in
// OPPOSITE directions):
//   work@sram2tlul  failLhs constant '' :0:0 {ct=0 sz=0 dec=}   (golden)
//                   failRhs operation '' :15:20                 (ours)
//                   `parameter logic [top_pkg::TL_AW-1:0] TlBaseAddr = 'h0`
//   work@jtag_mux   failLhs operation '' jtag_mux.sv:11:20      (golden)
//                   failRhs constant '' :0:0 {ct=0 sz=0 dec=}   (ours)
//                   `parameter logic [NumIOs-1:0] TieOffValues = '0`
// i.e. a bound naming a QUALIFIED PACKAGE parameter folds and a bound naming
// a MODULE parameter stays an operation — and we have both backwards.
package tlp;
  localparam int TL_AW = 32;
endpackage

module tl #(
  // A — the sram2tlul shape: qualified PACKAGE parameter bound
  parameter logic [tlp::TL_AW-1:0] A_PKG = 'h0,
  // B — the jtag_mux shape: MODULE parameter bound
  parameter int                    N     = 32,
  parameter logic [N-1:0]          B_MOD = '0,
  // C — literal-bound control
  parameter logic [7:0]            C_LIT = 'h1
) (
  input  logic clk_i,
  output logic z_o
);
  assign z_o = clk_i ^ A_PKG[0] ^ B_MOD[0] ^ C_LIT[0];
endmodule
