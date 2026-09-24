// r10earl7 witness tc — ENUM-MEMBER SUBSTITUTION, based-DECIMAL member.
// Census head (3 AllModules entries: ibex_core, ibex_cs_registers,
// rv_core_ibex):
//   constant '' ibex_cs_registers.sv:690:22 {ct=7 sz=4 dec=4}
//   vs                                      {ct=7 sz=4 dec=4'd4}
// i.e. golden substitutes `XDEBUGVER_STD` (a `4'd4` member of
// `typedef enum logic[3:0] {...} x_debug_ver_e`) with a BARE-DIGIT decompile
// where we keep the based-decimal spelling.  Both sides agree on
// vpiConstType 7 (INT) and vpiSize 4, and the ENUM_CONST object itself keeps
// `4'd4` on both sides — only the SUBSTITUTED copy differs.
// Rows: the corpus shape (structured pattern in an always_ff non-blocking
// assign), a package struct-pattern parameter, a module struct-pattern
// localparam, and the non-pattern controls (plain read / raw literal).
// The BIN member `PRIV_M = 2'b11` is the negative control: golden keeps
// `2'b11` / BIN / ct 3 in the substituted copy too.
package tcp;
  typedef enum logic [3:0] {
    XV_NO  = 4'd0,
    XV_STD = 4'd4,
    XV_HI  = 4'd15
  } x_ver_e;
  typedef enum logic [1:0] {
    PRIV_M = 2'b11,
    PRIV_U = 2'b00
  } priv_e;
  typedef enum logic [3:0] {
    HX_A = 4'h6,
    HX_B = 4'h9
  } hx_e;
  typedef struct packed {
    x_ver_e      xver;
    priv_e       prv;
    hx_e         hx;
  } small_t;
  typedef struct packed {
    x_ver_e      xver;
    priv_e       prv;
    logic [3:0]  pad;
  } dcsr_t;
  // A PACKAGE struct-pattern parameter over the same three members was
  // measured in an earlier revision (`localparam small_t PKG_DEF = '{xver:
  // XV_STD, prv: PRIV_M, hx: HX_A};`): golden strips the DEC row in BOTH
  // package views AND in the importing module's materialized copies — the
  // law holds in every view.  It is cut out of the witness because a
  // `import tcp::*` module then materializes PKG_DEF and drags in the whole
  // wildcard-import naming family (work@tc.PKG_DEF.* ref_typespec fullnames,
  // string_typespec parenting), which masks this one.
endpackage

module tc (
  input  logic clk_i,
  input  logic rst_ni,
  output logic [9:0] z_o
);
  import tcp::*;

  // MODULE struct-pattern localparam
  localparam small_t MOD_DEF = '{xver: XV_STD, prv: PRIV_M, hx: HX_A};

  dcsr_t dcsr_q;
  x_ver_e  plain_q;
  logic [3:0] based_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      // SUBJECT — the ibex_cs_registers shape
      dcsr_q  <= '{ xver: XV_STD, prv: PRIV_M, default: '0 };
      // CONTROLS — the same read outside a pattern
      plain_q <= XV_STD;
      based_q <= 4'd4;
    end
    else begin
      dcsr_q  <= dcsr_q;
      plain_q <= plain_q;
      based_q <= based_q;
    end
  end

  // NOTE: reading tcp::PKG_DEF from the module here pulls in the whole
  // wildcard-import MATERIALIZATION family (work@tc.PKG_DEF naming +
  // string_typespec parenting) and masks this law — the package parameter is
  // measured in its own two views instead.
  assign z_o = {dcsr_q, plain_q[1:0]} ^ {6'b0, based_q} ^ {2'b0, MOD_DEF};

endmodule
