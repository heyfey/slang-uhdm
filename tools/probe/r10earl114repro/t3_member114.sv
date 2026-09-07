// r10earl114 arm t3 -- THE MEMBER-KIND AXIS and THE GENERATE-DEPTH AXIS.
// MEASUREMENT ONLY.
//
// Surelog hangs the ROOT object's typespec on the path
// (CompileExpression.cpp:5463-5470), NOT the leaf member's -- the corpus head
// carries an `array_typespec` on a path whose LEAF is a one-bit `logic`.  This
// arm measures that claim directly: every cell below is the same root
// (`tl_h_i`, an unpacked array of a typedef'd packed struct, whose typespec is
// an `array_typespec`) with a DIFFERENT LEAF, and if the law is the root's then
// every cell hangs the SAME `array_typespec` regardless of the leaf's width,
// kind or depth.
//
// The DEPTH cells (d0..d4) repeat r10earl113's scope axis on THIS field, so the
// two laws are read on one grid: module body, generate-for depth 1 and 2,
// generate-if, generate-case.
package p114m;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
  typedef struct packed {
    logic       f0;
    logic [3:0] f1;
  } lo_t;
  typedef struct packed {
    lo_t        lo;
    logic [7:0] hi;
  } hi_t;
endpackage

module t3_member114 #(parameter int M = 3) (
  input  logic        clk,
  input  p114m::h2d_t tl_h_i [M],
  input  p114m::hi_t  nest_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  p114m::h2d_t d0_mod;

  // ---- THE MEMBER-KIND AXIS, all at generate depth 1 -------------------

  // m1  LEAF = a one-bit `logic` member (the corpus head's own leaf).
  for (genvar i = 0; i < M; i++) begin : gen_m1
    p114m::h2d_t m1_t;
    assign m1_t = '{ a_valid:  tl_h_i[i].a_valid,
                     a_opcode: p114m::OpA,
                     a_data:   d_i };
  end

  // m2  LEAF = an ENUM member.
  for (genvar i = 0; i < M; i++) begin : gen_m2
    p114m::h2d_t m2_t;
    assign m2_t = '{ a_valid:  1'b0,
                     a_opcode: tl_h_i[i].a_opcode,
                     a_data:   d_i };
  end

  // m3  LEAF = a packed-VECTOR member.
  for (genvar i = 0; i < M; i++) begin : gen_m3
    p114m::h2d_t m3_t;
    assign m3_t = '{ a_valid:  1'b1,
                     a_opcode: p114m::OpB,
                     a_data:   tl_h_i[i].a_data };
  end

  // m4  LEAF = a NESTED STRUCT member (the path stops on a struct, not a leaf).
  for (genvar i = 0; i < M; i++) begin : gen_m4
    p114m::hi_t m4_t;
    assign m4_t = '{ lo: nest_i[i].lo,
                     hi: d_i };
  end

  // m5  LEAF = a member of a nested struct, THREE components deep.
  for (genvar i = 0; i < M; i++) begin : gen_m5
    p114m::h2d_t m5_t;
    assign m5_t = '{ a_valid:  nest_i[i].lo.f0,
                     a_opcode: p114m::OpA,
                     a_data:   d_i };
  end

  // m6  LEAF = a BIT-SELECT on the member (a trailing select).
  for (genvar i = 0; i < M; i++) begin : gen_m6
    p114m::h2d_t m6_t;
    assign m6_t = '{ a_valid:  tl_h_i[i].a_data[0],
                     a_opcode: p114m::OpA,
                     a_data:   d_i };
  end

  // m7  LEAF = a PART-SELECT on the member (r10earl110's shape).
  for (genvar i = 0; i < M; i++) begin : gen_m7
    p114m::h2d_t m7_t;
    assign m7_t = '{ a_valid:  1'b0,
                     a_opcode: p114m::OpA,
                     a_data:   {4'h0, tl_h_i[i].a_data[7-:4]} };
  end

  // ---- THE DEPTH AXIS, the same leaf in every cell ---------------------

  // d0  MODULE BODY -- the scope negative control.
  assign d0_mod = '{ a_valid:  tl_h_i[0].a_valid,
                     a_opcode: tl_h_i[0].a_opcode,
                     a_data:   d_i };

  // d1  generate-for, depth 1.
  for (genvar i = 0; i < M; i++) begin : gen_d1
    p114m::h2d_t d1_t;
    assign d1_t = '{ a_valid:  tl_h_i[i].a_valid,
                     a_opcode: tl_h_i[i].a_opcode,
                     a_data:   d_i };
  end

  // d2  generate-for, depth 2.
  for (genvar i = 0; i < M; i++) begin : gen_d2a
    for (genvar j = 0; j < 2; j++) begin : gen_d2b
      p114m::h2d_t d2_t;
      assign d2_t = '{ a_valid:  tl_h_i[i].a_valid,
                       a_opcode: tl_h_i[i].a_opcode,
                       a_data:   d_i };
    end
  end

  // d3  generate-IF.
  if (M > 1) begin : gen_d3
    p114m::h2d_t d3_t;
    assign d3_t = '{ a_valid:  tl_h_i[0].a_valid,
                     a_opcode: tl_h_i[0].a_opcode,
                     a_data:   d_i };
  end

  // d4  generate-CASE.
  case (M)
    3: begin : gen_d4
      p114m::h2d_t d4_t;
      assign d4_t = '{ a_valid:  tl_h_i[1].a_valid,
                       a_opcode: tl_h_i[1].a_opcode,
                       a_data:   d_i };
    end
    default: begin : gen_d4d
      p114m::h2d_t d4d_t;
      assign d4d_t = '{ a_valid:  tl_h_i[0].a_valid,
                        a_opcode: tl_h_i[0].a_opcode,
                        a_data:   d_i };
    end
  endcase

  assign v_o = d0_mod.a_valid;
endmodule
