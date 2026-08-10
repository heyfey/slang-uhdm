// pf19.sv — § defGenPkgParamFoldQual19's matrix.  Pass 19 heads
// work@hmac (hmac.sv:506:26) and work@flash_phy_core
// (flash_phy_core.sv:190:27) are the SAME question in OPPOSITE directions:
// in a DEF-view generate context golden FOLDS `hmac_pkg::NumAlerts` written
// in a gen-for condition to a constant, and KEEPS `DataWidth` (the same
// package's parameter, reached through a wildcard import) as a ref_obj inside
// a gen-block always_comb.
//
// The pass-18 lesson: put the whole matrix in ONE file and read the two
// discriminators off one run.  Axes:
//   spelling  : QUALIFIED `p19::X` vs WILDCARD-IMPORTED `X`
//   container : gen-for condition / gen-if condition / gen-block cont_assign /
//               gen-block always_comb / module-body cont_assign (control)
package p19;
  parameter int QA = 3;
  parameter int QB = 4;
endpackage

module m19 (
  input  logic       clk,
  output logic [7:0] o
);
  import p19::*;

  // --- gen-for CONDITION: qualified vs wildcard --------------------------
  for (genvar i = 0; i < p19::QA; i++) begin : gen_forq
    logic [7:0] fq;
    assign fq = 8'(i);
  end
  for (genvar j = 0; j < QB; j++) begin : gen_forw
    logic [7:0] fw;
    assign fw = 8'(j);
  end

  // --- gen-if CONDITION: qualified vs wildcard ---------------------------
  if (p19::QA > 0) begin : gen_ifq
    logic [7:0] iq;
    assign iq = 8'd1;
  end
  if (QB > 0) begin : gen_ifw
    logic [7:0] iw;
    assign iw = 8'd2;
  end

  // --- gen-block BODY: cont_assign and always_comb, both spellings -------
  if (1) begin : gen_body
    logic [7:0] cq, cw, pq, pw;
    assign cq = {p19::QA{1'b1}};
    assign cw = {QB{1'b1}};
    always_comb pq = {p19::QA{1'b1}};
    always_comb pw = {QB{1'b1}};
  end

  // --- module-body controls (no generate) --------------------------------
  logic [7:0] mq, mw;
  assign mq = {p19::QA{1'b1}};
  assign mw = {QB{1'b1}};

  assign o = mq ^ mw;
endmodule
