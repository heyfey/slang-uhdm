// qa23 — GEN-SCOPE ENUM-TYPED LOCAL VARIABLES.  The pass-22 exit frontier is
// ibex_multdiv_fast's `gen_multiv_single_cycle`, whose gen_scope golden fills
// with 20 Variables where we emit 18: the two missing ones are the enum_vars
// of a GEN-BLOCK-LOCAL typedef enum, and the same scope's vpiTypedef vector is
// 1 vs 0.  The whole-arena enum_var census says the family is exactly 7
// objects in Earlgrey, in three shapes: a gen-local typedef enum
// (ibex_multdiv_fast, prim_diff_decode) and a PACKAGE enum typedef
// (ibex_wb_stage's `wb_instr_type_e wb_instr_type_q`).  Both are here, plus
// module-level controls of each so the gen-scope half is isolated.
package qa23_pkg;
  typedef enum logic [1:0] { P_A, P_B, P_C } pkg_e;
endpackage

module qa23_child #(parameter bit EN = 1'b1) (
  input  logic clk_i,
  input  logic sel_i,
  output logic [1:0] y_o
);
  import qa23_pkg::*;

  // module-level controls: both spellings outside any gen scope
  pkg_e m_pkg_q;
  typedef enum logic { M_X, M_Y } mod_e;
  mod_e m_mod_q;

  if (EN) begin : gen_en

    // (a) GEN-BLOCK-LOCAL typedef enum + two variables of it — the corpus
    //     shape (ibex_multdiv_fast.sv:132-136, prim_diff_decode.sv:48).
    typedef enum logic {
      G_LOW, G_HIGH
    } gen_fsm_e;
    gen_fsm_e g_state_q, g_state_d;

    // (b) a PACKAGE enum typedef local — ibex_wb_stage.sv:66.
    pkg_e g_pkg_q;

    // (c) plain logic locals so the Variables vector has a mixed population
    logic [1:0] g_plain_a, g_plain_b;

    always_comb begin
      g_state_d = G_LOW;
      if (sel_i) begin
        g_state_d = G_HIGH;
      end
    end

    always_ff @(posedge clk_i) begin
      g_state_q <= g_state_d;
    end

    assign g_plain_a = {1'b0, sel_i};
    assign g_plain_b = g_plain_a;
    assign y_o = (g_state_q == G_HIGH) ? 2'd3 : {1'b0, g_pkg_q[0]};
  end

  assign m_mod_q = M_X;
endmodule

module qa23 (
  input  logic clk_i,
  input  logic sel_i,
  output logic [1:0] y_o
);
  qa23_child #(.EN(1'b1)) u_child (.clk_i, .sel_i, .y_o);
endmodule
