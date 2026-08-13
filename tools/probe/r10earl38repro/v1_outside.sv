// r10earl38 VERIFIER arm v1_outside.sv — SHAPES NEITHER IMPLEMENTER GRID
// CONTAINS.  The implementer's own README.verifier.md § 3 names these as the
// place to look for a counterexample to the MONOTONE claim:
//   "a chain branch whose enclosing gen block is UNINSTANTIATED, or an else-if
//    chain under a `bind`, or one inside an interface definition".
// Added by the verifier: an else clause that is a BARE ITEM (not begin/end),
// a chain inside a CASE-GENERATE item, a chain under generate/endgenerate,
// and a chain inside a nested MODULE instantiated from a gen block.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.

package vp38;
  typedef logic [2:0] vp_t;
endpackage

//////////////////////////////////////////////////////////////////////////////
// V6 — a chain inside a MODULE that is itself instantiated inside a gen block.
//////////////////////////////////////////////////////////////////////////////
module sub38 #(parameter int unsigned SW = 2) (input logic s_i, output logic s_o);
  localparam bit [3:0] SubSel = 4'b0010;
  for (genvar q = 0; q < 2; q++) begin : gen_s
    if (SubSel[q] && SubSel[q+1]) begin : gen_s1
      logic s1_a, s1_b;
    end else if (SubSel[q]) begin : gen_s2
      logic s2_a, s2_b;
    end else begin : gen_s3
      logic s3_a, s3_b;
    end
  end
  assign s_o = s_i;
endmodule

//////////////////////////////////////////////////////////////////////////////
// V1 — a chain inside an INTERFACE definition.
//////////////////////////////////////////////////////////////////////////////
interface iface38 #(parameter int unsigned IW = 4) (input logic clk);
  localparam bit [3:0] ISel = 4'b0001;
  for (genvar k = 0; k < 4; k++) begin : gen_i
    if (ISel[k] && ISel[k]) begin : gen_i1
      logic i1_a, i1_b;
    end else if (ISel[k]) begin : gen_i2
      logic i2_a, i2_b;
    end else begin : gen_i3
      logic i3_a, i3_b;
    end
  end
endinterface

module vtop38 #(
    parameter int unsigned NP = 4,
    parameter bit          NEVER = 1'b0
) (
    input  logic [NP-1:0] a_i,
    output logic [NP-1:0] z_o
);
  import vp38::*;

  localparam bit [NP-1:0] SelA = 4'b0001;
  localparam bit [NP-1:0] SelB = 4'b0010;

  ////////////////////////////////////////////////////////////////////////////
  // V2 — the else clause is a BARE ITEM (no begin/end).  Tests whether the
  // `kind == IfGenerate` conjunct's abstention leaves a live defect: the
  // clause of `gen_b1`'s else is an IfGenerate, but the INNERMOST else clause
  // is a bare declaration/instance, not a GenerateBlock.
  ////////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_b
    if (SelA[k] && SelB[k]) begin : gen_b1
      logic b1_a, b1_b;
    end else if (SelB[k])
      logic b2_a, b2_b;                    // BARE else-if body, no begin/end
    else
      logic b3_a, b3_b;                    // BARE else body, no begin/end
  end

  ////////////////////////////////////////////////////////////////////////////
  // V3 — a chain inside a CASE-GENERATE item inside a gen-for (one level
  // deeper than a2's case cells, whose chains are at branch level).
  ////////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_c
    case (k)
      0: begin : gen_c0
        if (SelA[k] && SelB[k]) begin : gen_c0a
          logic c0a_x, c0a_y;
        end else if (SelA[k]) begin : gen_c0b
          logic c0b_x, c0b_y;
        end else begin : gen_c0c
          logic c0c_x, c0c_y;
        end
      end
      default: begin : gen_cd
        if (SelB[k]) begin : gen_cda
          logic cda_x, cda_y;
        end else if (SelA[k]) begin : gen_cdb
          logic cdb_x, cdb_y;
        end else begin : gen_cdc
          logic cdc_x, cdc_y;
        end
      end
    endcase
  end

  ////////////////////////////////////////////////////////////////////////////
  // V4 — a chain whose ENCLOSING gen block is UNINSTANTIATED (NEVER = 0), so
  // the enclosing gen-if is false and the whole subtree is uninstantiated.
  ////////////////////////////////////////////////////////////////////////////
  if (NEVER) begin : gen_u
    for (genvar k = 0; k < 2; k++) begin : gen_uf
      if (SelA[k] && SelB[k]) begin : gen_u1
        logic u1_a, u1_b;
      end else if (SelA[k]) begin : gen_u2
        logic u2_a, u2_b;
      end else begin : gen_u3
        logic u3_a, u3_b;
      end
    end
  end

  ////////////////////////////////////////////////////////////////////////////
  // V5 — a chain under an explicit generate/endgenerate region (R6's shape,
  // but with the chain rather than a bare gen-for).
  ////////////////////////////////////////////////////////////////////////////
  generate
    for (genvar k = 0; k < NP; k++) begin : gen_g
      if (SelA[k] && SelB[k]) begin : gen_g1
        logic g1_a, g1_b;
      end else if (SelA[k]) begin : gen_g2
        logic g2_a, g2_b;
      end else begin : gen_g3
        logic g3_a, g3_b;
      end
    end
  endgenerate

  ////////////////////////////////////////////////////////////////////////////
  // V7 — a chain inside a gen-for, branches carrying a PACKAGE-QUALIFIED type
  // and a nested sub-module instance (checks the newly reached branch's
  // instance HighConns and typespec policy together).
  ////////////////////////////////////////////////////////////////////////////
  for (genvar k = 0; k < NP; k++) begin : gen_h
    if (SelA[k] && SelB[k]) begin : gen_h1
      vp38::vp_t h1_a, h1_b;
      sub38 #(.SW(2)) u_h1 (.s_i(a_i[k]), .s_o());
    end else if (SelA[k]) begin : gen_h2
      vp38::vp_t h2_a, h2_b;
      sub38 #(.SW(2)) u_h2 (.s_i(a_i[k]), .s_o());
    end else begin : gen_h3
      vp_t h3_a, h3_b;
      sub38 #(.SW(2)) u_h3 (.s_i(a_i[k]), .s_o());
    end
  end

  iface38 #(.IW(4)) u_if (.clk(a_i[0]));

  assign z_o = a_i;
endmodule
