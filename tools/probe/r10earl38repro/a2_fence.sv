// r10earl38 — a2_fence.sv — THE OVER-FIRE FENCE.
//
// The head is a MISSING AST SCOPE on an `else if` chain branch nested inside a
// generate scope.  The scope gates FIVE separate emission loops in
// emitDefGenStmts' emitBranch, and restoring it lets ALL FIVE run where they
// previously abstained:
//
//     24376  gen-block LOCALPARAMs        (ParameterDeclarationStatement)
//     24646  gen-block VARIABLE DECLs     (DataDeclaration)          <- the head
//     26198  CASE-GENERATE item scopes
//     26259  NESTED IF-GENERATE branch scopes  (recursive)
//     26293  gen-block PROCESSES          (always* / initial)
//
// Every cell below puts one of those FOUR NON-HEAD categories in the newly
// reachable position (a chain branch inside a gen-for) so golden decides what
// belongs there, plus the shapes that must keep abstaining: a typedef'd type, a
// bare imported type, an unpacked array over a user type, a nested gen-for.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package fp38;
  typedef struct packed {
    logic       v;
    logic [2:0] d;
  } fs_t;
  typedef enum logic [1:0] { FA = 2'd0, FB = 2'd1 } fe_t;
  typedef logic [3:0] fl_t;
  localparam int unsigned FW = 4;
endpackage

module sub38 #(parameter int unsigned W = 1) (input logic i_i, output logic o_o);
  assign o_o = i_i;
endmodule

module fence38 #(
    parameter int unsigned NP = 4
) (
    input  logic [NP-1:0] a_i,
    output logic [NP-1:0] z_o
);
  import fp38::*;

  localparam bit [NP-1:0] SelA = 4'b0001;
  localparam bit [NP-1:0] SelB = 4'b0010;
  typedef logic [2:0] loc_t;

  //////////////////////////////////////////////////////////////////////////
  // F1 — LOCALPARAMS in a chain branch inside a gen-for (the 24376 loop).
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_f1
    if (SelA[k] && SelB[k]) begin : gen_f1a           // the `if` block — served
      localparam int          F1A_I = 7;
      localparam              F1A_U = 8;
      localparam logic [3:0]  F1A_V = 4'h3;
      localparam int          F1A_K = k;
    end else if (SelA[k]) begin : gen_f1b             // 2nd branch — NEW REACH
      localparam int          F1B_I = 7;
      localparam              F1B_U = 8;
      localparam logic [3:0]  F1B_V = 4'h3;
      localparam int          F1B_K = k;
    end else begin : gen_f1c                          // final else — NEW REACH
      localparam int          F1C_I = 7;
      localparam              F1C_U = 8;
    end
  end

  //////////////////////////////////////////////////////////////////////////
  // F2 — PROCESSES in a chain branch inside a gen-for (the 26293 loop).
  //////////////////////////////////////////////////////////////////////////
  logic clk_i, rst_ni;
  for (genvar k = 0; k < NP; k++) begin : gen_f2
    if (SelA[k] && SelB[k]) begin : gen_f2a           // served
      logic f2a_q;
      always_comb f2a_q = a_i[k];
      initial begin
        f2a_q = 1'b0;
      end
    end else if (SelA[k]) begin : gen_f2b             // NEW REACH
      logic f2b_q;
      always_comb f2b_q = a_i[k];
      initial begin
        f2b_q = 1'b0;
      end
      always_ff @(posedge clk_i) begin
        f2b_q <= a_i[k];
      end
    end else begin : gen_f2c                          // NEW REACH
      logic f2c_q;
      always_latch begin
        if (a_i[k]) f2c_q = 1'b1;
      end
    end
  end

  //////////////////////////////////////////////////////////////////////////
  // F3 — a CASE-GENERATE inside a chain branch (the 26198 loop).
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_f3
    if (SelA[k] && SelB[k]) begin : gen_f3a           // served
      case (k)
        0: begin : gen_f3a0
          logic f3a0_x, f3a0_y;
        end
        default: begin : gen_f3ad
          logic f3ad_x, f3ad_y;
        end
      endcase
    end else if (SelA[k]) begin : gen_f3b             // NEW REACH
      case (k)
        0: begin : gen_f3b0
          logic f3b0_x, f3b0_y;
        end
        default: begin : gen_f3bd
          logic f3bd_x, f3bd_y;
        end
      endcase
    end else begin : gen_f3c                          // NEW REACH
      case (k)
        2: begin : gen_f3c2
          logic f3c2_x, f3c2_y;
        end
        default: begin : gen_f3cd
          logic f3cd_x, f3cd_y;
        end
      endcase
    end
  end

  //////////////////////////////////////////////////////////////////////////
  // F4 — the TYPES that must keep abstaining, in the NEW REACH position:
  // a module-local typedef, a bare wildcard-imported package type, an
  // unpacked array over a user type — against the PACKAGE-QUALIFIED type,
  // which § defGenQualTypedefDecl says DOES stmt-ify.
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_f4
    if (SelA[k] && SelB[k]) begin : gen_f4a           // served — the control
      loc_t         f4a_loc;
      fs_t          f4a_bare;
      fp38::fs_t    f4a_qual;
      fp38::fe_t    f4a_qe;
      fp38::fl_t    f4a_ql;
      fs_t          f4a_arr [0:1];
      logic [2:0]   f4a_uarr [0:1];
    end else if (SelA[k]) begin : gen_f4b             // NEW REACH
      loc_t         f4b_loc;
      fs_t          f4b_bare;
      fp38::fs_t    f4b_qual;
      fp38::fe_t    f4b_qe;
      fp38::fl_t    f4b_ql;
      fs_t          f4b_arr [0:1];
      logic [2:0]   f4b_uarr [0:1];
    end else begin : gen_f4c                          // NEW REACH
      loc_t         f4c_loc;
      fp38::fs_t    f4c_qual;
    end
  end

  //////////////////////////////////////////////////////////////////////////
  // F5 — INSTANCES and CONT-ASSIGNS in the new-reach position: they never
  // needed the scope, so they must be byte-identical before and after.
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_f5
    if (SelA[k] && SelB[k]) begin : gen_f5a
      logic f5a_w;
      sub38 #(.W(1)) i_f5a (.i_i(a_i[k]), .o_o(f5a_w));
      assign z_o[k] = f5a_w;
    end else if (SelA[k]) begin : gen_f5b             // NEW REACH
      logic f5b_w;
      sub38 #(.W(1)) i_f5b (.i_i(a_i[k]), .o_o(f5b_w));
      assign z_o[k] = f5b_w;
    end else begin : gen_f5c                          // NEW REACH
      logic f5c_w;
      sub38 #(.W(1)) i_f5c (.i_i(a_i[k]), .o_o(f5c_w));
      assign z_o[k] = f5c_w;
    end
  end

  //////////////////////////////////////////////////////////////////////////
  // F6 — the ENCLOSING-CONSTRUCT axis: the same chain inside an explicit
  // `generate ... endgenerate` region, inside an UNCONDITIONAL named generate
  // block, and inside a CASE-GENERATE item.  Each is a different value of
  // `astBlock` at the recursion's entry.
  //////////////////////////////////////////////////////////////////////////
  generate
    for (genvar k = 0; k < NP; k++) begin : gen_f6r
      if (SelA[k] && SelB[k]) begin : gen_f6ra
        logic f6ra_a, f6ra_b;
      end else if (SelA[k]) begin : gen_f6rb
        logic f6rb_a, f6rb_b;
      end else begin : gen_f6rc
        logic f6rc_a, f6rc_b;
      end
    end
  endgenerate

  if (1) begin : gen_f6u                              // unconditional-ish block
    if (SelA[0] && SelB[0]) begin : gen_f6ua
      logic f6ua_a, f6ua_b;
    end else if (SelA[0]) begin : gen_f6ub
      logic f6ub_a, f6ub_b;
    end else begin : gen_f6uc
      logic f6uc_a, f6uc_b;
    end
  end

  for (genvar k = 0; k < NP; k++) begin : gen_f6c
    case (k)
      0: begin : gen_f6c0
        if (SelA[0] && SelB[0]) begin : gen_f6c0a
          logic f6c0a_a, f6c0a_b;
        end else if (SelA[0]) begin : gen_f6c0b
          logic f6c0b_a, f6c0b_b;
        end else begin : gen_f6c0c
          logic f6c0c_a, f6c0c_b;
        end
      end
      default: begin : gen_f6cd
        logic f6cd_a, f6cd_b;
      end
    endcase
  end

  //////////////////////////////////////////////////////////////////////////
  // F7 — DEPTH: a chain branch inside a chain branch inside a chain branch,
  // all inside a gen-for.  The scope has to thread through three recursions.
  //////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_f7
    if (SelA[k] && SelB[k]) begin : gen_f7a
      logic f7a_a;
    end else if (SelA[k]) begin : gen_f7b
      logic f7b_a;
      if (SelB[0]) begin : gen_f7b1
        logic f7b1_a;
      end else if (SelA[0]) begin : gen_f7b2
        logic f7b2_a;
        if (SelB[0]) begin : gen_f7b2x
          logic f7b2x_a;
        end else if (SelA[0]) begin : gen_f7b2y
          logic f7b2y_a;
        end else begin : gen_f7b2z
          logic f7b2z_a;
        end
      end else begin : gen_f7b3
        logic f7b3_a;
      end
    end else begin : gen_f7c
      logic f7c_a;
    end
  end

endmodule
