// r10earl113 arm s4 -- THE MUST-STAY FLOOR.  MEASUREMENT ONLY.
//
// Every cell here belongs to a COMMITTED law that this pass must not move:
//
//  f1  the committed "a re-emitted OUTERMOST pattern sizes its FIRST operand"
//      law at MODULE scope, on a packed-struct target -- the negative control
//      earl112's R0 names (golden DOES size);
//  f2  the same law on a TYPEDEF'd unpacked-array target, where golden sizes
//      operand 0 at the ELEMENT width (earl91 section 2 fact 5);
//  f3  § inlineUnpackedArrayPatternNoFirstSize91 -- an INLINE-spelled unpacked
//      array target, where golden already sizes NOTHING;
//  f4  § elabPatternFirstRowElemSize45 -- a NESTED unpacked-array pattern whose
//      OUTERMOST pattern stamps its own first operand;
//  f5  a 1-D unpacked array of EXPRESSIONS (the Kmac sha3_pkg.sv:20 shape),
//      where golden emits nothing and earl45's arm 3 removed all four stamps;
//  f6  § patCaGenIdxValueRender112's own corpus shape -- the gen-scope pattern
//      whose member values are dotted paths through a genvar-indexed array;
//  f7  § hpSelHalfOpParamFold110's plain gen-scope cont_assign select half,
//      beside the pattern, which must keep SPELLING the genvar.
package t113;
  typedef enum logic [2:0] { TA = 3'h0, TB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
  typedef logic [11:0] wd_t [2];
endpackage

module s4_fence113 #(parameter int M = 3, parameter int NH = 2) (
  input  logic        clk,
  input  t113::h2d_t  tl_h_i [M],
  input  logic [7:0]  d_i,
  input  logic [63:0] src_i,
  output logic        v_o
);
  // f1  MODULE-scope packed-struct pattern -- golden sizes operand 0
  t113::h2d_t f1_mod;
  assign f1_mod = '{ a_valid: tl_h_i[0].a_valid, a_opcode: t113::TA,
                     a_data:  d_i };

  // f2  TYPEDEF'd unpacked array target -- golden sizes operand 0 at 12
  t113::wd_t f2_td;
  assign f2_td = '{ {4'h0, d_i}, 12'h123 };

  // f3  INLINE-spelled unpacked array target -- golden sizes NOTHING (earl91)
  logic [11:0] f3_inline [NH];
  assign f3_inline = '{ {4'h0, d_i}, 12'h123 };

  // f4  NESTED unpacked-array pattern -- earl45's outermost-stamps-first law
  int f4_tab [2][3];
  assign f4_tab = '{ '{1, 2, 3}, '{4, 5, 6} };

  // f5  1-D unpacked array of EXPRESSIONS (the Kmac shape) -- no object
  localparam int F5_RATE [5] = '{1344/8, 1088/8, 832/8, 576/8, 448/8};

  // f6/f7  the gen-scope pattern beside the plain select half
  for (genvar i = 0; i < M; i++) begin : gen_f
    t113::h2d_t f6_pat;
    logic [1:0] f7_sel;
    // f7 -- earl110's shape: a plain cont_assign keeps the genvar SPELLED
    assign f7_sel = src_i[i*8 +: 2];
    // f6 -- earl112's shape: the pattern member values value-render the genvar
    assign f6_pat = '{ a_valid:  tl_h_i[i].a_valid,
                       a_opcode: tl_h_i[i].a_opcode,
                       a_data:   tl_h_i[i].a_data };
  end

  assign v_o = f1_mod.a_valid ^ f2_td[0][0] ^ f3_inline[0][0] ^
               (f4_tab[0][0] == F5_RATE[0]);
endmodule
