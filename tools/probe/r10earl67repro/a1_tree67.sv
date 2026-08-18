// r10earl67 arm 1 — THE HEAD'S OWN SHAPE, minimised.
// prim_arbiter_tree.sv:100-142: nested generate-for (`gen_tree` over `level`,
// `gen_level` over `offset`) whose BODIES declare `localparam int unsigned`
// from the genvars, read as the INDEX of a bit_select in a cont_assign that
// lives one gen scope DEEPER (`gen_nodes`, the else-branch of a generate-if).
// Contrast cells in the SAME file: distance 0 (same block), distance 2, a
// genvar in the same position, a module localparam, a package parameter and a
// port parameter, and every other operand position.
package a1pkg67;
  localparam int unsigned PKGP = 3;
endpackage

module a1sub67 #(parameter int unsigned PP = 2) (input logic [7:0] v, output logic o);
  assign o = v[PP];
endmodule

module a1_tree67 #(parameter int unsigned NumLevels = 2) (
    input  logic [7:0] req,
    input  logic [7:0] rr_q,
    output logic [7:0] out
);
  import a1pkg67::*;
  localparam int unsigned MLP = 2;                 // module-body localparam
  logic [15:0] req_tree;
  logic [15:0] idx_tree;
  assign req_tree = {8'h0, req};

  for (genvar level = 0; level < NumLevels; level++) begin : gen_tree
    localparam int unsigned Base0 = (2**level)-1;
    localparam int unsigned Base1 = (2**(level+1))-1;
    for (genvar offset = 0; offset < 2**level; offset++) begin : gen_level
      localparam int unsigned Pa = Base0 + offset;
      localparam int unsigned C0 = Base1 + 2*offset;
      localparam int unsigned C1 = Base1 + 2*offset + 1;
      // distance 0: read in the SAME gen block as the declaration
      logic d0_idx, d0_bare, d0_op, d0_cat, d0_tern, d0_ips, d0_ps;
      assign d0_idx  = req_tree[C0];
      assign d0_bare = C0[0];
      assign d0_op   = req_tree[C0 + 1];
      assign d0_cat  = |{req_tree[C0], req_tree[C1]};
      assign d0_tern = (C0 > 0) ? req_tree[1] : req_tree[2];
      assign d0_ips  = |req_tree[C0 +: 2];
      assign d0_ps   = |idx_tree[C1:C0];
      if (level == NumLevels) begin : gen_leafs
        assign out[offset] = req_tree[Pa];
      end else begin : gen_nodes
        // distance 1: THE HEAD.  C0/C1/Pa declared one gen scope UP.
        logic sel;
        logic h_bare, h_op, h_cat, h_rep, h_tern, h_ips, h_ipsw, h_ps, h_gv, h_mlp, h_pkg;
        assign sel    = ~req_tree[C0] | req_tree[C1] & rr_q[NumLevels-1-level];
        assign h_bare = C0[0];
        assign h_op   = req_tree[C0 + 1];
        assign h_cat  = |{req_tree[C0], 1'b0};
        assign h_rep  = |{2{req_tree[C1]}};
        assign h_tern = (C0 > 0) ? req_tree[1] : req_tree[2];
        assign h_ips  = |req_tree[C0 +: 2];
        assign h_ipsw = |req_tree[0 +: 2];
        assign h_ps   = |idx_tree[C1:C0];
        assign h_gv   = req_tree[offset];       // GENVAR in the same position
        assign h_mlp  = req_tree[MLP];          // MODULE localparam
        assign h_pkg  = req_tree[PKGP];         // PACKAGE parameter
        assign out[Pa] = sel;
        // distance 2: one more gen scope down
        if (1) begin : gen_deep
          logic d2_idx;
          assign d2_idx = req_tree[C0];
          if (1) begin : gen_deeper
            logic d3_idx;
            assign d3_idx = req_tree[C0];
          end
        end
        a1sub67 #(.PP(C0)) u_sub (.v(req), .o(idx_tree[Pa]));
      end
    end
  end
endmodule
