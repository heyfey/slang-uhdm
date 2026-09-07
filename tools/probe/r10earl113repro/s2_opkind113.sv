// r10earl113 arm s2 -- THE OPERAND-KIND AXIS.  MEASUREMENT ONLY.
//
// The same keyed struct pattern in a gen-scope cont_assign and in its
// MODULE-scope twin, with operand 0 taking a different KIND in every cell:
// hier_path, plain ref_obj, sized constant, UNSIZED constant ('1 / '0 --
// the only thing `ExprEval::flattenPatternAssignments` itself ever resizes,
// and only at `VpiSize == -1`), an operation, a bit_select, a part_select and
// a concatenation.  POSITIONAL (untagged) twins ride beside the keyed ones,
// because `flattenPatternAssignments` RETURNS EARLY on an untagged operand
// that is an operation or a constant (ExprEval.cpp:858-864), which is itself
// an axis of the law's population.
//
// Every struct carries an ENUM member so that Surelog models the assigned
// object as a `struct_var` and the generate unrolling's `cont_assign::DeepClone`
// flatten fires -- see s1's header.
package q113;
  typedef enum logic [2:0] { QA = 3'h0, QB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
  typedef struct packed {
    logic [3:0] lo;
    op_e        mid;
    logic [3:0] hi;
  } pair_t;
  // THE CONSTANT DISCRIMINATOR: a first member EIGHT bits wide, so a 4-bit
  // literal first operand can tell "golden kept the literal's own width" from
  // "golden wrote the member width".
  typedef struct packed {
    logic [7:0] w0;
    op_e        w1;
  } wide_t;
endpackage

module s2_opkind113 #(parameter int M = 3) (
  input  logic          clk,
  input  q113::h2d_t    tl_h_i [M],
  input  logic          sv_i,
  input  logic [7:0]    d_i,
  input  logic [15:0]   w_i,
  output logic          v_o
);
  // ---- MODULE-SCOPE TWINS (the negative controls) ----------------------
  q113::h2d_t  k1_mod, k2_mod, k3_mod, k4_mod, k5_mod, k6_mod, k7_mod;
  q113::pair_t k8_mod;
  q113::h2d_t  p1_mod, p4_mod;

  assign k1_mod = '{ a_valid: tl_h_i[0].a_valid, a_opcode: q113::QA,
                     a_data:  d_i };                      // hier_path first
  assign k2_mod = '{ a_valid: sv_i, a_opcode: q113::QA,
                     a_data:  d_i };                      // ref_obj first
  assign k3_mod = '{ a_valid: 1'b1, a_opcode: q113::QA,
                     a_data:  d_i };                      // sized constant
  assign k4_mod = '{ a_valid: '1, a_opcode: q113::QA,
                     a_data:  '0 };                       // UNSIZED constants
  assign k5_mod = '{ a_valid: sv_i & tl_h_i[0].a_valid, a_opcode: q113::QA,
                     a_data:  d_i };                      // operation first
  assign k6_mod = '{ a_valid: w_i[3], a_opcode: q113::QA,
                     a_data:  d_i };                      // bit_select first
  assign k7_mod = '{ a_valid: sv_i, a_opcode: q113::QA,
                     a_data:  w_i[11:4] };                // part_select later
  assign k8_mod = '{ lo: {2'b01, w_i[1:0]}, mid: q113::QB,
                     hi: 4'h3 };                          // concat first
  assign p1_mod = '{ tl_h_i[0].a_valid, q113::QA, d_i };  // POSITIONAL
  assign p4_mod = '{ '1, q113::QA, '0 };                  // POSITIONAL unsized

  // n1/n2  THE CONSTANT DISCRIMINATOR at module scope: a 4-bit literal and an
  //        unsized '1 into an EIGHT-bit first member.
  q113::wide_t n1_mod, n2_mod;
  assign n1_mod = '{ w0: 4'h3, w1: q113::QA };
  assign n2_mod = '{ w0: '1,   w1: q113::QA };

  // ---- GEN-SCOPE CELLS -------------------------------------------------
  for (genvar i = 0; i < M; i++) begin : gen_k
    q113::h2d_t  k1_gen, k2_gen, k3_gen, k4_gen, k5_gen, k6_gen, k7_gen;
    q113::pair_t k8_gen;
    q113::h2d_t  p1_gen, p4_gen;

    assign k1_gen = '{ a_valid: tl_h_i[i].a_valid, a_opcode: q113::QA,
                       a_data:  d_i };                    // hier_path first
    assign k2_gen = '{ a_valid: sv_i, a_opcode: q113::QA,
                       a_data:  d_i };                    // ref_obj first
    assign k3_gen = '{ a_valid: 1'b1, a_opcode: q113::QA,
                       a_data:  d_i };                    // sized constant
    assign k4_gen = '{ a_valid: '1, a_opcode: q113::QA,
                       a_data:  '0 };                     // UNSIZED constants
    assign k5_gen = '{ a_valid: sv_i & tl_h_i[i].a_valid, a_opcode: q113::QA,
                       a_data:  d_i };                    // operation first
    assign k6_gen = '{ a_valid: w_i[3], a_opcode: q113::QA,
                       a_data:  d_i };                    // bit_select first
    assign k7_gen = '{ a_valid: sv_i, a_opcode: q113::QA,
                       a_data:  w_i[11:4] };              // part_select later
    assign k8_gen = '{ lo: {2'b01, w_i[1:0]}, mid: q113::QB,
                       hi: 4'h3 };                        // concat first
    assign p1_gen = '{ tl_h_i[i].a_valid, q113::QA, d_i };   // POSITIONAL
    assign p4_gen = '{ '1, q113::QA, '0 };                   // POSITIONAL

    // n1/n2  THE CONSTANT DISCRIMINATOR in the generate scope
    q113::wide_t n1_gen, n2_gen;
    assign n1_gen = '{ w0: 4'h3, w1: q113::QA };
    assign n2_gen = '{ w0: '1,   w1: q113::QA };
  end

  assign v_o = k1_mod.a_valid ^ p1_mod.a_valid ^ k8_mod.hi[0] ^
               n1_mod.w0[0] ^ n2_mod.w0[1];
endmodule
