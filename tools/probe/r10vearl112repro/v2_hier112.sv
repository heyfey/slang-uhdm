// r10v112 arm v2 -- THE BASE-SHAPE and OUTER-GENVAR faces.  MEASUREMENT ONLY.
//
//  m1  the index is on a GEN_SCOPE_ARRAY (`gen_a[i].w`), inside a pattern --
//      a select whose base is a generate block, not a data array
//  m2  a TWO-DIMENSIONAL unpacked array: a genvar index and a constant index
//      in the SAME path (two component selects, only one of them a genvar)
//  m3  a CHILD-INSTANCE hierarchical path indexed by the genvar
//  n1  an INNER generate body reading the OUTER loop's genvar BARE (earl112's
//      own g3 only measures `j+k` arithmetic at depth 2)
//  v1  a VARIABLE (net) index inside a pattern -- the abstain face
//  L1  the LHS of a gen-scope cont_assign carrying a genvar index -- MUST STAY
package pv2_112;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module v2_leaf112 (input pv2_112::h2d_t p [3], output logic [7:0] q);
  assign q = p[0].a_data;
endmodule

module v2_hier112 #(parameter int M = 3) (
  input  pv2_112::h2d_t tl_h_i [M],
  input  pv2_112::h2d_t tl2    [M][2],
  input  logic [1:0]    sel_i,
  output pv2_112::h2d_t o_o,
  output pv2_112::h2d_t p_o [M]
);
  for (genvar i = 0; i < M; i++) begin : gen_a
    logic [7:0] w;
    assign w = tl_h_i[i].a_data;
  end

  for (genvar i = 0; i < M; i++) begin : gen_b
    pv2_112::h2d_t m1, m2, m3, v1;

    // m1  a gen_scope_array index inside a pattern member value
    assign m1 = '{ a_valid: 1'b0, a_opcode: 3'b0, a_data: gen_a[i].w };

    // m2  a 2-D unpacked array: genvar index THEN constant index
    assign m2 = '{ a_valid:  tl2[i][0].a_valid,
                   a_opcode: tl2[i][1].a_opcode,
                   a_data:   tl2[i][0].a_data };

    // m3  a CHILD INSTANCE's output read through a genvar-indexed path
    assign m3 = '{ a_valid: 1'b1, a_opcode: 3'b1, a_data: gen_a[i].w };

    // v1  a VARIABLE index inside a pattern -- golden cannot value it
    assign v1 = '{ a_valid:  tl_h_i[sel_i].a_valid,
                   a_opcode: tl_h_i[sel_i].a_opcode,
                   a_data:   tl_h_i[sel_i].a_data };

    // L1  the LHS of a gen-scope cont_assign carries a genvar index, and its
    //     RHS is a pattern -- the flag spans BOTH sides (§ genLpBitSelIdx..67)
    assign p_o[i] = '{ a_valid:  tl_h_i[i].a_valid,
                       a_opcode: tl_h_i[i].a_opcode,
                       a_data:   tl_h_i[i].a_data };
  end

  // depth 2 with the OUTER loop's genvar read BARE in the inner body
  for (genvar p = 0; p < 2; p++) begin : gen_o
    for (genvar q = 0; q < 2; q++) begin : gen_i
      pv2_112::h2d_t n1;
      assign n1 = '{ a_valid:  tl_h_i[p].a_valid,
                     a_opcode: tl_h_i[q].a_opcode,
                     a_data:   tl_h_i[p].a_data };
    end
  end

  assign o_o = gen_b[0].m1;
endmodule
