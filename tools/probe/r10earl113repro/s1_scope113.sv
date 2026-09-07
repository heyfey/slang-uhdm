// r10earl113 arm s1 -- THE SCOPE AXIS.  MEASUREMENT ONLY.
//
// The corpus head is tlul_socket_m1.sv:108-118
//     assign hreq_fifo_i = '{ a_valid: tl_h_i[i].a_valid, ... };
// inside `for (genvar i...) begin : gen_host_fifo`.  Golden leaves the FIRST
// operand of that pattern with NO VpiSize; we stamp the member width (1).
//
// THE SHAPE THAT REPRODUCES IT, measured and not assumed: the assigned struct
// must be modelled by Surelog as a `struct_var`, because UHDM's
// `cont_assign::DeepClone` (clone_tree.cpp:803-816) -- the pass that unrolls a
// generate body -- flattens the pattern ONLY when the Lhs is a `ref_obj` whose
// `Actual_group` is a `struct_var` with a resolved typespec, and it flattens
// WITHOUT ever calling `adjustOpSize`.  A struct of pure `logic` members driven
// by a continuous assign comes out a `struct_net` (cell x1 below) and golden
// then keeps the `tagged_pattern` untouched.  An ENUM member is what makes the
// corpus's `tlul_pkg::tl_h2d_t` a struct_var, so every cell here carries one.
//
// Every cell is the SAME keyed struct pattern with the SAME first-operand
// shape, moved from scope to scope: module body, generate-for depth 1,
// generate-for depth 2, generate-if, generate-case.  The MODULE-scope cell is
// the NEGATIVE CONTROL: golden DOES size operand 0 there.
package p113;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
  // the same struct with NO enum member -- Surelog models it as a struct_net
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_net_t;
endpackage

module s1_scope113 #(parameter int M = 3) (
  input  logic         clk,
  input  p113::h2d_t   tl_h_i [M],
  input  logic [7:0]   d_i,
  output logic         v_o
);
  // m1  MODULE SCOPE -- the negative control (golden sizes operand 0)
  p113::h2d_t m1_mod;
  assign m1_mod = '{ a_valid:  tl_h_i[0].a_valid,
                     a_opcode: tl_h_i[0].a_opcode,
                     a_data:   d_i };

  // g1  GENERATE-FOR, DEPTH 1 -- the head shape (golden: NO size)
  for (genvar i = 0; i < M; i++) begin : gen_d1
    p113::h2d_t g1_keyed;
    assign g1_keyed = '{ a_valid:  tl_h_i[i].a_valid,
                         a_opcode: tl_h_i[i].a_opcode,
                         a_data:   d_i };
  end

  // g2  GENERATE-FOR, DEPTH 2
  for (genvar i = 0; i < M; i++) begin : gen_d2a
    for (genvar j = 0; j < 2; j++) begin : gen_d2b
      p113::h2d_t g2_keyed;
      assign g2_keyed = '{ a_valid:  tl_h_i[i].a_valid,
                           a_opcode: tl_h_i[i].a_opcode,
                           a_data:   d_i };
    end
  end

  // g3  GENERATE-IF (a gen_scope with no unrolled loop above it)
  if (M > 1) begin : gen_if
    p113::h2d_t g3_keyed;
    assign g3_keyed = '{ a_valid:  tl_h_i[0].a_valid,
                         a_opcode: tl_h_i[0].a_opcode,
                         a_data:   d_i };
  end

  // g4  GENERATE-CASE
  case (M)
    3: begin : gen_case
      p113::h2d_t g4_keyed;
      assign g4_keyed = '{ a_valid:  tl_h_i[1].a_valid,
                           a_opcode: tl_h_i[1].a_opcode,
                           a_data:   d_i };
    end
    default: begin : gen_case_d
      p113::h2d_t g4d_keyed;
      assign g4d_keyed = '{ a_valid:  tl_h_i[0].a_valid,
                            a_opcode: tl_h_i[0].a_opcode,
                            a_data:   d_i };
    end
  endcase

  // x1  THE CLONE GATE's own negative control: a pure-logic struct comes out a
  //     struct_net, the deep clone never flattens, golden keeps the tags.
  for (genvar i = 0; i < M; i++) begin : gen_net
    p113::h2d_net_t x1_net;
    assign x1_net = '{ a_valid:  tl_h_i[i].a_valid,
                       a_opcode: 3'b010,
                       a_data:   d_i };
  end

  // x2  THE FENCE'S OWN CELL: the pattern is inside a generate block but the
  //     TARGET is declared in the MODULE BODY.  Surelog's `bindVariable`
  //     (CompileStmt.cpp:3089-3148) has no `gen_scope` case and recurses to the
  //     parent, so it FINDS a module-body target from inside a generate block:
  //     `writeCont_assign`'s `tps` is filled, `expandPatternAssignment` runs,
  //     and golden SIZES operand 0 exactly as at module scope.  This is
  //     uhdm2rtlil's `gen_struct_access/dut.sv` and Surelog's
  //     `tests/FuncAlias/dut.sv`, both of which a gate without the fence
  //     converted from CMP_EQUAL to CMP_NOTEQUAL in both modes.
  p113::h2d_t x2_modtgt;
  if (M > 1) begin : gen_modtgt
    assign x2_modtgt = '{ a_valid:  tl_h_i[0].a_valid,
                          a_opcode: tl_h_i[0].a_opcode,
                          a_data:   d_i };
  end

  // x3  a MODULE-SCOPE ARRAY ELEMENT driven from a generate for: the Lhs is a
  //     `bit_select`, not a `ref_obj`, so `writeCont_assign`'s
  //     `lhs->UhdmType() == uhdmref_obj` arm never runs at all.
  p113::h2d_t x3_arr [M];
  for (genvar i = 0; i < M; i++) begin : gen_arrtgt
    assign x3_arr[i] = '{ a_valid:  tl_h_i[i].a_valid,
                          a_opcode: tl_h_i[i].a_opcode,
                          a_data:   d_i };
  end

  assign v_o = m1_mod.a_valid ^ x2_modtgt.a_valid ^ x3_arr[0].a_valid;
endmodule
